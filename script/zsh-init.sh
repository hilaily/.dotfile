#!/bin/bash
# 链接 zshrc、安装 Oh My Zsh，并将默认 shell 设为 zsh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: zsh-init

1. 将 ~/.zshrc 链接到 ~/.dotfile/zsh/.zshrc
2. 若未安装则安装 Oh My Zsh（--unattended --keep-zshrc）
3. 将默认登录 shell 设为 zsh

选项:
  -h, --help  显示此帮助

本机额外配置可写入 ~/.zshrc.local。
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

set -euo pipefail

DOTFILE="${DOTFILE:-$HOME/.dotfile}"
ZSHRC_REPO="$DOTFILE/zsh/.zshrc"
ZSHRC_HOME="$HOME/.zshrc"

echo "Link zshrc"
if [[ -f "$ZSHRC_HOME" && ! -L "$ZSHRC_HOME" ]]; then
    mv "$ZSHRC_HOME" "$ZSHRC_HOME.bak"
    echo "  已备份原文件 -> $ZSHRC_HOME.bak"
fi
ln -sf "$ZSHRC_REPO" "$ZSHRC_HOME"
echo "  $ZSHRC_HOME -> $ZSHRC_REPO"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "安装 Oh My Zsh…"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
else
    echo "Oh My Zsh 已存在，跳过安装 (~/.oh-my-zsh)"
fi

echo ""
echo "将默认登录 shell 设为 zsh"
zshpath="$(command -v zsh)"
if [[ -z "$zshpath" || ! -x "$zshpath" ]]; then
    echo "错误: 找不到可执行的 zsh，请先安装 zsh。" >&2
    exit 1
fi
if grep -qxF "$zshpath" /etc/shells 2>/dev/null; then
    echo "  $zshpath 已在 /etc/shells 中"
else
    echo "$zshpath" | sudo tee -a /etc/shells
fi
chsh -s "$zshpath"

echo ""
echo "完成。默认 shell 已改为: $zshpath"
echo "请重新登录或新开终端后生效。"
