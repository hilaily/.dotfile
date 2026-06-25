#!/usr/bin/env bash
# 将标准输入复制到系统剪贴板（macOS / Linux X11 / Wayland）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: clip-copy

从 stdin 读取内容并写入系统剪贴板。

支持:
  macOS: pbcopy
  Wayland: wl-copy
  X11: xclip / xsel

选项:
  -h, --help  显示此帮助

示例:
  echo hello | clip-copy
  cat file.txt | clip-copy
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

set -euo pipefail

if command -v pbcopy >/dev/null 2>&1; then
    pbcopy
elif [ "${XDG_SESSION_TYPE:-}" = wayland ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
    if command -v wl-copy >/dev/null 2>&1; then
        wl-copy --no-newline
    else
        echo "clip-copy: wl-copy not found (Wayland session)" >&2
        exit 1
    fi
elif [ -n "${DISPLAY:-}" ]; then
    if command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard
    elif command -v xsel >/dev/null 2>&1; then
        xsel --clipboard --input
    else
        echo "clip-copy: xclip or xsel not found (DISPLAY=$DISPLAY)" >&2
        exit 1
    fi
elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard
elif command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --input
else
    echo "clip-copy: no clipboard tool (pbcopy / wl-copy / xclip / xsel)" >&2
    exit 1
fi
