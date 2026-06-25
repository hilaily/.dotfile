#!/bin/bash
# 链接 tmux 配置并安装 TPM 插件

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: tmux-init

1. 将 ~/.tmux.conf 链接到 ~/.dotfile/tmux/.tmux.conf
2. 克隆 tpm 到 ~/.tmux/plugins/tpm（若不存在）
3. 安装插件并 reload tmux 配置

选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

set -euo pipefail

echo 'Init tmux config'
src=$HOME/.tmux.conf
if [ -e "$src" ]; then
    mv "$src" "$src.bak"
fi
ln -s "$HOME/.dotfile/tmux/.tmux.conf" "$src"

echo 'Install tpm'
if [ ! -e ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo 'Install tmux plugin by tpm'
"$HOME/.tmux/plugins/tpm/bin/install_plugins"

echo 'Reload tmux'
tmux source ~/.tmux.conf
