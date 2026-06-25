#!/bin/bash
# 将 Cursor 用户配置链接到 dotfile（macOS）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: cursor-init

链接 ~/.dotfile/cursor/config/ 下的 settings.json、keybindings.json
到 Cursor 用户目录（macOS）。

已有文件会备份为 *.bak。

选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

set -euo pipefail

echo 'Cursor config init'

src="$HOME/Library/Application Support/Cursor/User/settings.json"
if [ -f "$src" ]; then
    mv "$src" "$src.bak"
fi
ln -s "$HOME/.dotfile/cursor/config/settings.json" "$src"

src="$HOME/Library/Application Support/Cursor/User/keybindings.json"
if [ -f "$src" ]; then
    mv "$src" "$src.bak"
fi
ln -s "$HOME/.dotfile/cursor/config/keybindings.json" "$src"
