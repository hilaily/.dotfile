#!/bin/bash
# 将 ~/.gitconfig 链接到 dotfile，并设置 Linux 凭据脚本可执行

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: git-init

备份已有 ~/.gitconfig，软链接到 ~/.dotfile/git/.gitconfig。
同时为 git-credential.sh 添加可执行权限。

凭据由 ~/.dotfile/git/git-credential.sh 处理（兼容 Git < 2.36，低版本回退 store）。

选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

set -euo pipefail

echo 'Init git config'
src=$HOME/.gitconfig
if [ -f "$src" ]; then
    mv "$src" "$src.bak"
fi
ln -s "$HOME/.dotfile/git/.gitconfig" "$src"

chmod +x "$HOME/.dotfile/git/git-credential.sh"
# 兼容旧路径：若仍存在则保持可执行
chmod +x "$HOME/.dotfile/git/git-credential-linux.sh" 2>/dev/null || true
