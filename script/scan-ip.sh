#!/bin/bash

echo "--- 步骤 1: 正在尝试自动检测本地 IP ---"

# 1. 尝试使用 ip 或 ifconfig 命令获取本地 IP 地址
# 优先使用 ip (Linux 常用)，其次使用 ifconfig (macOS 常用)
if command -v ip &>/dev/null; then
    # Linux 方式：排除环回地址，只取第一条结果，并去除 /CIDR 部分
    LOCAL_IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n 1)
elif command -v ifconfig &>/dev/null; then
    # macOS 方式：排除环回地址，只取第一条结果
    LOCAL_IP=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -n 1)
else
    echo "错误: 找不到 ip 或 ifconfig 命令。无法确定本地 IP，请手动检查网络配置。"
    exit 1
fi

# 检查是否成功获取 IP
if [ -z "$LOCAL_IP" ]; then
    echo "错误: 未能找到有效的本地 IP 地址 (非 127.0.0.1)。"
    exit 1
fi

# 2. 提取网段前缀 (例如 192.168.1.100 -> 192.168.1.)
# ${LOCAL_IP%.*} 使用 Shell 参数扩展来移除最后一个点之后的所有字符
NETWORK_PREFIX="${LOCAL_IP%.*}."

echo "✅ 已检测到本地 IP: ${LOCAL_IP}"
echo "▶️ 开始扫描网段: ${NETWORK_PREFIX}1 到 ${NETWORK_PREFIX}254"
echo "------------------------------------------------------"

# 3. 遍历 ping 扫描
# -c 1: 发送 1 个包
# -W 1: 等待 1 秒超时
# >/dev/null 2>&1: 丢弃所有输出
# &: 在后台运行，以并行加速扫描
for i in {1..254}; do
    ping -c 1 -W 1 "${NETWORK_PREFIX}${i}" >/dev/null 2>&1 &
done

# 4. 等待所有后台 ping 任务完成
# 这一步是确保所有 Ping 完成后，ARP 表才会被完整填充
wait

echo "------------------------------------------------------"
echo "✅ Ping 扫描完成。正在检查 ARP 表以显示活跃主机..."

# 5. 检查 ARP 表以获取活跃 IP 和 MAC 地址
# -a: 显示所有 ARP 条目
# grep -v "incomplete": 排除未解析成功的条目
# grep "${NETWORK_PREFIX%.*}": 只显示当前网段的条目
arp -a | grep -v "incomplete" | grep "${NETWORK_PREFIX%.*}"

echo "------------------------------------------------------"
echo "扫描结束。"
