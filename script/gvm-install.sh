#!/bin/bash
# 安装 gvm（Go 版本管理）并配置 fish 与默认 Go 版本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: gvm-install

1. 安装 gvm
2. 为 fish 安装 fish-gvm、bass 插件
3. 安装并设置 go1.24.0 为默认版本

选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

set -e

bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

fish -c "fisher install JGAntunes/fish-gvm"
fish -c "fisher install edc/bass"

fish -c "gvm install go1.24.0 -B"
fish -c "gvm use go1.24.0 --default"
