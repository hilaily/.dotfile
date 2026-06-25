#!/bin/bash
# Linux 凭据 helper：优先 libsecret，否则回退 cache 并提示安装
set -euo pipefail

warn_missing_libsecret() {
    local marker="${XDG_CACHE_HOME:-$HOME/.cache}/git-credential-linux.warned"
    [[ -f "$marker" ]] && return 0
    mkdir -p "$(dirname "$marker")"
    touch "$marker"
    cat >&2 <<'EOF'
提示: 未找到 git-credential-libsecret，当前使用内存缓存（默认 1 周过期或登出后失效）。

安装持久化凭据存储:
  Debian/Ubuntu:  sudo apt install libsecret-1-0 git-credential-libsecret
  Fedora/RHEL:    sudo dnf install git-credential-libsecret
  Arch Linux:     sudo pacman -S libsecret git
EOF
}

if command -v git-credential-libsecret >/dev/null 2>&1; then
    exec git-credential-libsecret "$@"
fi

warn_missing_libsecret
exec git-credential-cache --timeout=604800 "$@"
