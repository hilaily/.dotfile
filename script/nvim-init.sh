#!/bin/bash
# 将 Neovim 配置目录链接到 dotfile/nvim

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: nvim-init

将 ~/.config/nvim 软链接到 ~/.dotfile/nvim。
已有配置会备份为 nvim.backup.<时间戳>。

选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

NVIM_CONFIG_DIR="$HOME/.config/nvim"
YOUR_CUSTOM_CONFIG_DIR="$HOME/.dotfile/nvim"

if [ -L "$NVIM_CONFIG_DIR" ] && [ "$(readlink -f "$NVIM_CONFIG_DIR")" = "$(readlink -f "$YOUR_CUSTOM_CONFIG_DIR")" ]; then
    echo "软链接已经存在并指向正确的目录。无需进行任何操作。"
    exit 0
fi

if [ -e "$NVIM_CONFIG_DIR" ]; then
    echo "检测到现有的 Neovim 配置。"
    if [ -d "$NVIM_CONFIG_DIR" ] || [ -f "$NVIM_CONFIG_DIR" ]; then
        BACKUP_DIR="$NVIM_CONFIG_DIR.backup.$(date +%Y%m%d%H%M%S)"
        mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
        echo "已将现有配置备份到 $BACKUP_DIR"
    else
        rm "$NVIM_CONFIG_DIR"
        echo "已删除现有的无效配置。"
    fi
fi

ln -s "$YOUR_CUSTOM_CONFIG_DIR" "$NVIM_CONFIG_DIR"

if [ -L "$NVIM_CONFIG_DIR" ] && [ "$(readlink -f "$NVIM_CONFIG_DIR")" = "$(readlink -f "$YOUR_CUSTOM_CONFIG_DIR")" ]; then
    echo "软链接创建成功。Neovim 现在将使用您的自定义配置。"
else
    echo "创建软链接时出错。请检查路径和权限。"
    exit 1
fi
