#!/bin/bash
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
  echo "安装 Oh My Zsh（--unattended：安装脚本内不改 shell、不自动进 zsh；--keep-zshrc：保留已链接的 .zshrc）…"
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
echo "完成。当前仓库的 .zshrc 已启用 z 插件（Oh My Zsh plugins/z），默认 shell 已改为: $zshpath"
echo "请重新登录或新开终端后生效。本机额外配置可写入 ~/.zshrc.local（不会被链接覆盖）。"
