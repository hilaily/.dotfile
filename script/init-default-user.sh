#!/bin/bash

# 初始化默认用户脚本
# 用于创建 ace 用户并给予 sudo 权限

set -e  # 遇到错误时立即退出

# 检查是否以 root 身份运行
if [[ $EUID -ne 0 ]]; then
    echo "错误：此脚本必须以 root 身份运行"
    echo "请使用: sudo $0"
    exit 1
fi

USERNAME="ace"

echo "开始创建用户 $USERNAME..."

# 检查用户是否已存在
if id "$USERNAME" &>/dev/null; then
    echo "用户 $USERNAME 已存在"
else
    # 创建用户
    useradd -m -s /bin/bash "$USERNAME"
    echo "用户 $USERNAME 创建成功"
    
    # 设置用户密码
    echo "请为用户 $USERNAME 设置密码："
    passwd "$USERNAME"
fi

# 检查 sudo 组是否存在
if ! getent group sudo &>/dev/null; then
    echo "警告：sudo 组不存在，尝试创建..."
    groupadd sudo
fi

# 将用户添加到 sudo 组
usermod -aG sudo "$USERNAME"
echo "用户 $USERNAME 已添加到 sudo 组"

# 检查 /etc/sudoers 文件中的 sudo 组配置
if ! grep -q "^%sudo" /etc/sudoers; then
    echo "配置 sudoers 文件..."
    echo "%sudo   ALL=(ALL:ALL) ALL" >> /etc/sudoers
    echo "sudoers 配置已更新"
fi

# 验证用户创建和 sudo 权限
echo ""
echo "验证用户信息："
echo "用户 ID: $(id $USERNAME)"
echo "用户组: $(groups $USERNAME)"

# 创建用户家目录的基本配置
USER_HOME="/home/$USERNAME"
if [ -d "$USER_HOME" ]; then
    # 设置正确的目录权限
    chown -R "$USERNAME:$USERNAME" "$USER_HOME"
    chmod 755 "$USER_HOME"
    
    # 创建基本的 .bashrc 文件（如果不存在）
    if [ ! -f "$USER_HOME/.bashrc" ]; then
        cp /etc/skel/.bashrc "$USER_HOME/.bashrc" 2>/dev/null || true
        chown "$USERNAME:$USERNAME" "$USER_HOME/.bashrc"
    fi
    
    echo "用户家目录配置完成"
fi

echo ""
echo "✅ 用户 $USERNAME 创建完成并已获得 sudo 权限"
echo "💡 提示："
echo "   - 用户可以使用 'sudo' 命令执行管理员操作"
echo "   - 首次使用 sudo 时需要输入用户密码"
echo "   - 可以使用 'su - $USERNAME' 切换到该用户"
echo ""
echo "脚本执行完成！"
