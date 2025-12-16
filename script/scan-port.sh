#!/bin/bash

# 端口扫描脚本
# 用法: ./scan-port.sh <IP地址> [端口范围]
# 示例: ./scan-port.sh 192.168.1.1
# 示例: ./scan-port.sh 192.168.1.1 80,443,8080
# 示例: ./scan-port.sh 192.168.1.1 1-1000

# 检查是否提供了 IP 地址参数
if [ -z "$1" ]; then
    echo "错误: 请提供要扫描的 IP 地址"
    echo "用法: $0 <IP地址> [端口范围]"
    echo "示例: $0 192.168.1.1"
    echo "示例: $0 192.168.1.1 80,443,8080"
    echo "示例: $0 192.168.1.1 1-1000"
    exit 1
fi

TARGET_IP="$1"
TIMEOUT=1  # 连接超时时间（秒）

# 验证 IP 地址格式（简单验证）
if ! [[ "$TARGET_IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "错误: 无效的 IP 地址格式: $TARGET_IP"
    exit 1
fi

echo "=========================================="
echo "正在扫描 IP: $TARGET_IP"
echo "=========================================="

# 检查是否有 nc (netcat) 命令
if ! command -v nc &>/dev/null; then
    echo "错误: 找不到 nc (netcat) 命令。"
    echo "请安装 netcat:"
    echo "  macOS: brew install netcat"
    echo "  Linux: sudo apt-get install netcat 或 sudo yum install nc"
    exit 1
fi

# 确定要扫描的端口
if [ -z "$2" ]; then
    # 如果没有指定端口，扫描常用端口
    PORTS=(21 22 23 25 53 80 110 111 135 139 143 443 445 993 995 1723 3306 3389 5432 5900 8080 8443)
    echo "使用默认常用端口列表"
else
    # 解析端口参数
    PORT_SPEC="$2"
    
    # 检查是否是范围格式 (例如: 1-1000)
    if [[ "$PORT_SPEC" =~ ^[0-9]+-[0-9]+$ ]]; then
        START_PORT=$(echo "$PORT_SPEC" | cut -d'-' -f1)
        END_PORT=$(echo "$PORT_SPEC" | cut -d'-' -f2)
        
        if [ "$START_PORT" -gt "$END_PORT" ]; then
            echo "错误: 起始端口 ($START_PORT) 不能大于结束端口 ($END_PORT)"
            exit 1
        fi
        
        PORTS=($(seq "$START_PORT" "$END_PORT"))
        echo "扫描端口范围: $START_PORT-$END_PORT (共 $((END_PORT - START_PORT + 1)) 个端口)"
    # 检查是否是逗号分隔的端口列表 (例如: 80,443,8080)
    elif [[ "$PORT_SPEC" =~ ^[0-9,]+$ ]]; then
        IFS=',' read -ra PORTS <<< "$PORT_SPEC"
        echo "扫描指定端口: $PORT_SPEC"
    else
        echo "错误: 无效的端口格式: $PORT_SPEC"
        echo "支持的格式:"
        echo "  - 逗号分隔: 80,443,8080"
        echo "  - 范围: 1-1000"
        exit 1
    fi
fi

echo "超时设置: ${TIMEOUT}秒"
echo "------------------------------------------------------"

# 统计变量
OPEN_PORTS=()
CLOSED_COUNT=0
TOTAL_PORTS=${#PORTS[@]}

# 扫描端口函数
scan_port() {
    local port=$1
    local ip=$2
    
    # 使用 nc 扫描端口
    # -z: 只扫描，不发送数据
    # -v: 详细输出
    # -w: 超时时间
    if nc -z -v -w "$TIMEOUT" "$ip" "$port" 2>&1 | grep -q "succeeded\|open"; then
        echo "✅ 端口 $port: 开放"
        return 0
    else
        return 1
    fi
}

# 并行扫描端口（使用后台任务）
for port in "${PORTS[@]}"; do
    if scan_port "$port" "$TARGET_IP"; then
        OPEN_PORTS+=("$port")
    else
        ((CLOSED_COUNT++))
    fi
done

# 等待所有后台任务完成
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

