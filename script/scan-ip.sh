#!/bin/bash
# ICMP/TCP 扫描本网段或指定网段的在线主机、主机名与开放端口

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: scan-ip [端口或网段参数...]

扫描局域网主机:
  无参数              ICMP 扫描本网段 .1-.254，并尽力显示主机名
  10.0.0              扫描指定网段前缀
  22                  扫描本网段 TCP 22 端口
  80,443,8080         扫描多个端口（任一开放即显示）
  22 10.0.0           指定网段 + 端口（顺序不限）

选项:
  -h, --help  显示此帮助

依赖: ping；端口模式需要 nc (netcat)。
      主机名: macOS 使用系统解析器；Linux 使用 NSS（getent），安装 avahi-utils 时也会查询 mDNS；均会回退反向 DNS。
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

TIMEOUT=1

is_port_spec() {
    [[ "$1" =~ ^[0-9]+$ || "$1" =~ ^[0-9]+-[0-9]+$ || "$1" =~ ^[0-9,]+$ ]]
}

is_ip_prefix() {
    [[ "$1" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){1,3}$ ]]
}

PORT_SPEC=""
PREFIX_ARG=""

if [ -n "$1" ] && is_ip_prefix "$1"; then
    PREFIX_ARG="$1"
    [ -n "$2" ] && is_port_spec "$2" && PORT_SPEC="$2"
elif [ -n "$1" ]; then
    is_port_spec "$1" && PORT_SPEC="$1"
    [ -n "$2" ] && is_ip_prefix "$2" && PREFIX_ARG="$2"
fi

if [ -n "$1" ] && [ -z "$PORT_SPEC" ] && [ -z "$PREFIX_ARG" ]; then
    echo "错误: 无法识别参数: $1"
    usage
    exit 1
fi

if command -v ip &>/dev/null; then
    LOCAL_IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n 1)
elif command -v ifconfig &>/dev/null; then
    LOCAL_IP=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -n 1)
else
    echo "错误: 找不到 ip 或 ifconfig 命令" && exit 1
fi

[ -z "$LOCAL_IP" ] && echo "错误: 未能检测到本地 IP" && exit 1

if [ -n "$PREFIX_ARG" ]; then
    PREFIX="$PREFIX_ARG"
else
    PREFIX="${LOCAL_IP%.*}"
fi

PORTS=()
if [ -n "$PORT_SPEC" ]; then
    if [[ "$PORT_SPEC" =~ ^[0-9]+$ ]]; then
        PORTS=("$PORT_SPEC")
    elif [[ "$PORT_SPEC" =~ ^[0-9]+-[0-9]+$ ]]; then
        START_PORT=${PORT_SPEC%-*}
        END_PORT=${PORT_SPEC#*-}
        if [ "$START_PORT" -gt "$END_PORT" ]; then
            echo "错误: 起始端口 ($START_PORT) 不能大于结束端口 ($END_PORT)" && exit 1
        fi
        for p in $(seq "$START_PORT" "$END_PORT"); do PORTS+=("$p"); done
    elif [[ "$PORT_SPEC" =~ ^[0-9,]+$ ]]; then
        IFS=',' read -ra PORTS <<<"$PORT_SPEC"
    else
        echo "错误: 无效的端口格式: $PORT_SPEC"
        exit 1
    fi
fi

echo "本机 IP: $LOCAL_IP，扫描网段: $PREFIX.1-254"
if [ ${#PORTS[@]} -gt 0 ]; then
    echo "扫描端口: ${PORTS[*]} (TCP，超时 ${TIMEOUT}s)"
else
    echo "扫描模式: ICMP (在线检测)"
fi
echo "------------------------------------------------------"

hostname_for_ip() {
    local ip="$1"
    local hostname=""

    # macOS 的系统解析器包含本机 hosts、DNS 和可用的 Bonjour/mDNS 记录。
    if [ "$(uname -s)" = "Darwin" ] && command -v dscacheutil &>/dev/null; then
        hostname=$(dscacheutil -q host -a ip_address "$ip" 2>/dev/null \
            | awk -F': ' '/^name: / {print $2; exit}')
    fi

    # Linux 的 NSS 配置可包含 /etc/hosts、DNS 与 mDNS（例如 libnss-mdns）。
    if [ -z "$hostname" ] && command -v getent &>/dev/null; then
        hostname=$(getent hosts "$ip" 2>/dev/null | awk 'NR == 1 {print $2}')
    fi

    # 未配置 NSS mDNS 时，avahi-utils 仍可直接查询局域网的 .local 名称。
    if [ -z "$hostname" ] && command -v avahi-resolve-address &>/dev/null; then
        if command -v timeout &>/dev/null; then
            hostname=$(timeout 1 avahi-resolve-address -4 "$ip" 2>/dev/null \
                | awk -F '\t' 'NR == 1 {print $2}')
        else
            hostname=$(avahi-resolve-address -4 "$ip" 2>/dev/null \
                | awk -F '\t' 'NR == 1 {print $2}')
        fi
    fi

    # 没有本地记录时再查询 PTR；限制超时，避免名称解析拖慢扫描。
    if [ -z "$hostname" ] && command -v dig &>/dev/null; then
        # macOS 的 dig 会在 DNS 超时时将 ";; connection timed out" 输出到 stdout。
        # PTR 记录只接受由主机名字符组成的一行，避免将诊断信息显示为主机名。
        hostname=$(dig +time=1 +tries=1 +short -x "$ip" 2>/dev/null \
            | awk '/^[[:alnum:]_][[:alnum:]_.-]*\.?$/ {print; exit}')
    fi

    # PTR 记录通常以点结尾，显示时去掉以保持紧凑。
    printf '%s' "${hostname%.}"
}

format_host() {
    local ip="$1"
    local hostname
    hostname=$(hostname_for_ip "$ip")

    if [ -n "$hostname" ]; then
        printf '%s (%s)' "$ip" "$hostname"
    else
        printf '%s' "$ip"
    fi
}

if [ ${#PORTS[@]} -eq 0 ]; then
    if [ "$(uname -s)" = "Darwin" ]; then
        for i in $(seq 1 254); do
            (
                ip="$PREFIX.$i"
                ping -c 1 -W 1000 -S "$LOCAL_IP" "$ip" >/dev/null 2>&1 \
                    && echo "$(format_host "$ip") 在线"
            ) &
        done
    else
        for i in $(seq 1 254); do
            (
                ip="$PREFIX.$i"
                ping -c 1 -W 1 -I "$LOCAL_IP" "$ip" >/dev/null 2>&1 \
                    && echo "$(format_host "$ip") 在线"
            ) &
        done
    fi
    wait
    echo "------------------------------------------------------"
    echo "扫描完成"
    exit 0
fi

if ! command -v nc &>/dev/null; then
    echo "错误: 找不到 nc (netcat)"
    exit 1
fi

NC_OPTS=(-z -w "$TIMEOUT")
if [ "$(uname -s)" = "Darwin" ]; then
    NC_OPTS+=(-G "$TIMEOUT")
fi

check_host() {
    local ip="$1"
    local hit=()
    for port in "${PORTS[@]}"; do
        if nc "${NC_OPTS[@]}" "$ip" "$port" >/dev/null 2>&1; then
            hit+=("$port")
        fi
    done
    if [ ${#hit[@]} -gt 0 ]; then
        echo "$(format_host "$ip") 开放: ${hit[*]}"
    fi
}

for i in $(seq 1 254); do
    check_host "$PREFIX.$i" &
done
wait

echo "------------------------------------------------------"
echo "扫描完成"
