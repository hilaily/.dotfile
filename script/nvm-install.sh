#!/bin/bash
# 安装 fnm（Node 版本管理）并 reload fish 配置

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: nvm-install

通过 fnm 官方安装脚本安装 Fast Node Manager，并执行 ff reload。

选项:
  -h, --help  显示此帮助

说明: 本仓库 fish 配置中 nvm 别名指向 fnm。
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

set -euo pipefail

curl -fsSL https://fnm.vercel.app/install | bash

if command -v ff &>/dev/null; then
    ff reload
elif command -v fish &>/dev/null; then
    fish -c "source ~/.config/fish/config.fish"
fi
