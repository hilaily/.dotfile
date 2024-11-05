#!/bin/bash

# 定义变量
NVIM_CONFIG_DIR="$HOME/.config/nvim"
YOUR_CUSTOM_CONFIG_DIR="$HOME/.dotfile/nvim"  # 请替换为您的自定义配置目录路径

# 检查软链接是否已经存在并指向正确的目录
if [ -L "$NVIM_CONFIG_DIR" ] && [ "$(readlink -f "$NVIM_CONFIG_DIR")" = "$(readlink -f "$YOUR_CUSTOM_CONFIG_DIR")" ]; then
    echo "软链接已经存在并指向正确的目录。无需进行任何操作。"
    exit 0
fi

# 检查是否存在现有的 Neovim 配置
if [ -e "$NVIM_CONFIG_DIR" ]; then
    echo "检测到现有的 Neovim 配置。"
    
    # 如果是目录或常规文件，创建备份
    if [ -d "$NVIM_CONFIG_DIR" ] || [ -f "$NVIM_CONFIG_DIR" ]; then
        BACKUP_DIR="$NVIM_CONFIG_DIR.backup.$(date +%Y%m%d%H%M%S)"
        mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
        echo "已将现有配置备份到 $BACKUP_DIR"
    else
        # 如果是其他类型的文件（如损坏的软链接），直接删除
        rm "$NVIM_CONFIG_DIR"
        echo "已删除现有的无效配置。"
    fi
fi

# 创建软链接
ln -s "$YOUR_CUSTOM_CONFIG_DIR" "$NVIM_CONFIG_DIR"

# 检查软链接是否创建成功
if [ -L "$NVIM_CONFIG_DIR" ] && [ "$(readlink -f "$NVIM_CONFIG_DIR")" = "$(readlink -f "$YOUR_CUSTOM_CONFIG_DIR")" ]; then
    echo "软链接创建成功。Neovim 现在将使用您的自定义配置。"
else
    echo "创建软链接时出错。请检查路径和权限。"
fi

