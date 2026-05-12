#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SRC="$HOME/.dotfile/ghostty/config"
DEST="$HOME/.config/ghostty/config"

echo -e "${YELLOW}初始化 Ghostty 配置...${NC}"

# 目标目录不存在则创建
mkdir -p "$(dirname "$DEST")"

# 已经是指向正确位置的软链接，无需操作
if [ -L "$DEST" ] && [ "$(readlink -f "$DEST")" = "$(readlink -f "$SRC")" ]; then
    echo -e "${GREEN}软链接已存在且指向正确位置，无需操作。${NC}"
    exit 0
fi

# 存在旧文件/目录则备份
if [ -e "$DEST" ]; then
    BACKUP="${DEST}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$DEST" "$BACKUP"
    echo -e "${YELLOW}已将现有配置备份到 $BACKUP${NC}"
elif [ -L "$DEST" ]; then
    # 损坏的旧软链接
    rm "$DEST"
fi

ln -s "$SRC" "$DEST"

if [ -L "$DEST" ] && [ "$(readlink -f "$DEST")" = "$(readlink -f "$SRC")" ]; then
    echo -e "${GREEN}软链接创建成功：$DEST -> $SRC${NC}"
else
    echo -e "${RED}软链接创建失败，请检查路径和权限。${NC}"
    exit 1
fi
