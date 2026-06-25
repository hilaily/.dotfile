#!/bin/bash
# 清理 Homebrew 缓存与无用文件

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: brew-clean

执行 Homebrew 清理（brew cleanup），删除旧版本与缓存。

选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

set -euo pipefail

if ! command -v brew &>/dev/null; then
    echo "错误: 未找到 brew，请先安装 Homebrew" >&2
    exit 1
fi

brew cleanup
