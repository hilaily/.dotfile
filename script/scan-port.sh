#!/bin/bash
# 对指定 IP 进行 TCP 端口扫描

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: scan-port <IP> [端口范围]

扫描目标 IP 的 TCP 端口（使用 nc）。

参数:
  IP            目标 IPv4 地址（必填）
  端口范围      可选。默认扫描常用端口列表。
                支持: 80,443,8080  或  1-1000

选项:
  -h, --help  显示此帮助

示例:
  scan-port 192.168.1.1
  scan-port 192.168.1.1 22,80,443
  scan-port 192.168.1.1 1-1000
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

if [ -z "$1" ]; then
    echo "错误: 请提供要扫描的 IP 地址" >&2
    usage
    exit 1
fi

TARGET_IP="$1"
TIMEOUT=1

if ! [[ "$TARGET_IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "错误: 无效的 IP 地址格式: $TARGET_IP"
    exit 1
fi

echo "=========================================="
echo "正在扫描 IP: $TARGET_IP"
echo "=========================================="

if ! command -v nc &>/dev/null; then
    echo "错误: 找不到 nc (netcat) 命令。"
    exit 1
fi

if [ -z "$2" ]; then
    PORTS=(21 22 23 25 53 80 110 111 135 139 143 443 445 993 995 1723 3306 3389 5432 5900 8080 8443)
    echo "使用默认常用端口列表"
else
    PORT_SPEC="$2"

    if [[ "$PORT_SPEC" =~ ^[0-9]+-[0-9]+$ ]]; then
        START_PORT=$(echo "$PORT_SPEC" | cut -d'-' -f1)
        END_PORT=$(echo "$PORT_SPEC" | cut -d'-' -f2)

        if [ "$START_PORT" -gt "$END_PORT" ]; then
            echo "错误: 起始端口 ($START_PORT) 不能大于结束端口 ($END_PORT)"
            exit 1
        fi

        PORTS=($(seq "$START_PORT" "$END_PORT"))
        echo "扫描端口范围: $START_PORT-$END_PORT"
    elif [[ "$PORT_SPEC" =~ ^[0-9,]+$ ]]; then
        IFS=',' read -ra PORTS <<<"$PORT_SPEC"
        echo "扫描指定端口: $PORT_SPEC"
    else
        echo "错误: 无效的端口格式: $PORT_SPEC"
        exit 1
    fi
fi

echo "超时设置: ${TIMEOUT}秒"
echo "------------------------------------------------------"

OPEN_PORTS=()
CLOSED_COUNT=0
TOTAL_PORTS=${#PORTS[@]}

scan_port() {
    local port=$1
    local ip=$2

    if nc -z -v -w "$TIMEOUT" "$ip" "$port" 2>&1 | grep -q "succeeded\|open"; then
        echo "✅ 端口 $port: 开放"
        return 0
    else
        return 1
    fi
}

for port in "${PORTS[@]}"; do
    if scan_port "$port" "$TARGET_IP"; then
        OPEN_PORTS+=("$port")
    else
        ((CLOSED_COUNT++))
    fi
done

wait

echo "------------------------------------------------------"
echo "扫描完成！"
echo "=========================================="
echo "总计扫描端口数: $TOTAL_PORTS"
echo "开放端口数: ${#OPEN_PORTS[@]}"
echo "关闭端口数: $CLOSED_COUNT"

if [ ${#OPEN_PORTS[@]} -gt 0 ]; then
    echo ""
    echo "开放的端口列表:"
    for port in "${OPEN_PORTS[@]}"; do
        echo "  - $port"
    done
else
    echo ""
    echo "未发现开放的端口"
fi

echo "=========================================="
