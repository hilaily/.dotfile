#!/bin/bash

if command -v ip &>/dev/null; then
    LOCAL_IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n 1)
elif command -v ifconfig &>/dev/null; then
    LOCAL_IP=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -n 1)
else
    echo "错误: 找不到 ip 或 ifconfig 命令" && exit 1
fi

[ -z "$LOCAL_IP" ] && echo "错误: 未能检测到本地 IP" && exit 1

PREFIX="${LOCAL_IP%.*}"
echo "本机 IP: $LOCAL_IP，扫描网段: $PREFIX.1-254"
echo "------------------------------------------------------"

# macOS: -W 单位毫秒，-S 绑定源 IP
# Linux:  -W 单位秒，  -I 绑定源 IP
# 绑定源 IP 是为了防止 VPN 劫持路由导致 ping 走错网卡、ARP 不触发
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
