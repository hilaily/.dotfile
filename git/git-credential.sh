#!/bin/bash
# 跨平台 Git 凭据 helper（不依赖 includeIf ondarwin/onlinux，兼容 Git < 2.36）
# macOS: osxkeychain → store
# Linux:  libsecret → store
set -euo pipefail

warn_store_fallback() {
    local reason="$1"
    local marker="${XDG_CACHE_HOME:-$HOME/.cache}/git-credential-store.warned"
    [[ -f "$marker" ]] && return 0
    mkdir -p "$(dirname "$marker")"
    touch "$marker"
    cat >&2 <<EOF
提示: Git 凭据使用 store 明文保存到 ~/.git-credentials（${reason}）。

建议:
  macOS:  通常可用 osxkeychain（Keychain）
  Linux:  sudo apt install libsecret-1-0 git-credential-libsecret

请确保 ~/.git-credentials 权限为 600。
EOF
}

case "$(uname -s)" in
Darwin)
    if command -v git-credential-osxkeychain >/dev/null 2>&1; then
        exec git-credential-osxkeychain "$@"
    fi
    warn_store_fallback "未找到 osxkeychain"
    exec git-credential-store "$@"
    ;;
Linux)
    if command -v git-credential-libsecret >/dev/null 2>&1; then
        exec git-credential-libsecret "$@"
    fi
    warn_store_fallback "未找到 git-credential-libsecret"
    exec git-credential-store "$@"
    ;;
*)
    warn_store_fallback "未知系统 $(uname -s)"
    exec git-credential-store "$@"
    ;;
esac
