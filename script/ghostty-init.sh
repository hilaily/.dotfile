#!/bin/bash
# 将 Ghostty 配置链接到 dotfile（macOS / Linux）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: ghostty-init

将 ~/.dotfile/ghostty/config.ghostty 软链接到 Ghostty 配置目录:
  macOS: ~/Library/Application Support/com.mitchellh.ghostty/
  Linux: $XDG_CONFIG_HOME/ghostty/

已有配置会备份为 *.backup.<时间戳>。

选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SRC="$HOME/.dotfile/ghostty/config.ghostty"

if [[ "$(uname)" == "Darwin" ]]; then
    DEST="$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
else
    CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
    DEST="$CONFIG_HOME/ghostty/config.ghostty"
fi

echo -e "${YELLOW}初始化 Ghostty 配置...${NC}"
echo -e "${YELLOW}目标路径：$DEST${NC}"

mkdir -p "$(dirname "$DEST")"

if [ -L "$DEST" ] && [ "$(readlink -f "$DEST")" = "$(readlink -f "$SRC")" ]; then
    echo -e "${GREEN}软链接已存在且指向正确位置，无需操作。${NC}"
    exit 0
fi

if [ -e "$DEST" ]; then
    BACKUP="${DEST}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$DEST" "$BACKUP"
    echo -e "${YELLOW}已将现有配置备份到 $BACKUP${NC}"
elif [ -L "$DEST" ]; then
    rm "$DEST"
fi

ln -s "$SRC" "$DEST"

if [ -L "$DEST" ] && [ "$(readlink -f "$DEST")" = "$(readlink -f "$SRC")" ]; then
    echo -e "${GREEN}软链接创建成功：$DEST -> $SRC${NC}"
else
    echo -e "${RED}软链接创建失败，请检查路径和权限。${NC}"
    exit 1
fi
