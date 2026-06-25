#!/bin/bash
# ICMP/TCP 扫描本网段或指定网段的在线主机与开放端口

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: scan-ip [端口或网段参数...]

扫描局域网主机:
  无参数              ICMP 扫描本网段 .1-.254
  10.0.0              扫描指定网段前缀
  22                  扫描本网段 TCP 22 端口
  80,443,8080         扫描多个端口（任一开放即显示）
  22 10.0.0           指定网段 + 端口（顺序不限）

选项:
  -h, --help  显示此帮助

依赖: ping；端口模式需要 nc (netcat)。
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

if [ ${#PORTS[@]} -eq 0 ]; then
    if [ "$(uname -s)" = "Darwin" ]; then
        for i in $(seq 1 254); do
            ping -c 1 -W 1000 -S "$LOCAL_IP" "$PREFIX.$i" >/dev/null 2>&1 && echo "$PREFIX.$i 在线" &
        done
    else
        for i in $(seq 1 254); do
            ping -c 1 -W 1 -I "$LOCAL_IP" "$PREFIX.$i" >/dev/null 2>&1 && echo "$PREFIX.$i 在线" &
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
        echo "$ip 开放: ${hit[*]}"
    fi
}

for i in $(seq 1 254); do
    check_host "$PREFIX.$i" &
done
wait

echo "------------------------------------------------------"
echo "扫描完成"
