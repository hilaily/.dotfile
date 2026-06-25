#!/bin/bash

# 用法:
#   ./scan-ip.sh                  # ICMP 扫描本网段在线 IP
#   ./scan-ip.sh 10.0.0           # ICMP 扫描指定网段（10.0.0.1-254）
#   ./scan-ip.sh 22               # 扫描本网段中 22 端口开放的 IP
#   ./scan-ip.sh 80,443,8080      # 扫描本网段中任一指定端口开放的 IP
#   ./scan-ip.sh 22 10.0.0        # 指定网段前缀 + 端口（顺序不限）
#   ./scan-ip.sh 10.0.0 22        # 同上

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
    echo "端口支持: 单端口(22) / 列表(80,443) / 范围(8000-8100)"
    echo "网段支持: 前缀(10.0.0 或 192.168.1.0)"
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

# 解析端口参数 -> PORTS 数组
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
        echo "支持: 单端口(22) / 列表(80,443) / 范围(8000-8100)"
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

# ---------- 模式一：ICMP 在线扫描（无端口参数） ----------
if [ ${#PORTS[@]} -eq 0 ]; then
    # macOS: -W 单位毫秒，-S 绑定源 IP
    # Linux: -W 单位秒，  -I 绑定源 IP
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

# ---------- 模式二：TCP 端口扫描 ----------
if ! command -v nc &>/dev/null; then
    echo "错误: 找不到 nc (netcat)，请先安装："
    echo "  macOS: brew install netcat"
    echo "  Debian/Ubuntu: sudo apt-get install netcat-openbsd"
    exit 1
fi

# nc 在不同实现里 -z/-w 行为基本一致；用 -G 在 macOS 上控制连接超时更准
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
