#!/bin/bash
# 下载 Fira Code 字体压缩包并打开所在目录（需手动安装）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: firacode-install

从 GitHub 下载 Fira Code v6.2 到 ~/Downloads/，并打开 Finder/文件管理器。
需在图形界面中解压并安装字体文件。

选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

set -euo pipefail

cd ~/Downloads/
wget https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip

echo '1. unzip Fira_Code_v6.2.zip'
echo '2. select all file and install it'

open ~/Downloads/
