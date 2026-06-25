#!/bin/bash
# 从 GitHub Release 安装 Neovim 到 /usr/local/nvim

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: nvim-install

按当前平台下载 Neovim v0.12.2 预编译包，安装到 /usr/local/nvim，
并链接 nvim/vim 到 /usr/local/bin。

支持: macOS x86_64/arm64, Linux x86_64/arm64

选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

set -e

os_arch=$(uname -s)-$(uname -m)
ver=v0.12.2

case $os_arch in
"Darwin-x86_64")
    cd /tmp
    rm -rf nvim-macos-x86_64.tar.gz
    wget "https://github.com/neovim/neovim/releases/download/$ver/nvim-macos-x86_64.tar.gz"
    tar zxf nvim-macos-x86_64.tar.gz
    sudo mv -f /usr/local/nvim /usr/local/nvim-bak 2>/dev/null || true
    sudo mv nvim-macos-x86_64 /usr/local/nvim
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/vim
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim
    vim -v
    ;;
"Darwin-arm64" | "Darwin-aarch64")
    cd /tmp
    rm -rf nvim-macos-arm64.tar.gz
    wget "https://github.com/neovim/neovim/releases/download/$ver/nvim-macos-arm64.tar.gz"
    tar zxf nvim-macos-arm64.tar.gz
    [ -e /usr/local/nvim ] && sudo mv -f /usr/local/nvim /usr/local/nvim-bak
    sudo mv nvim-macos-arm64 /usr/local/nvim
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/vim
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim
    vim -v
    ;;
"Linux-x86_64")
    cd /tmp
    rm -rf nvim-linux-x86_64.tar.gz
    wget "https://github.com/neovim/neovim/releases/download/$ver/nvim-linux-x86_64.tar.gz"
    tar zxf nvim-linux-x86_64.tar.gz
    [ -e /usr/local/nvim ] && sudo mv -f /usr/local/nvim /usr/local/nvim-bak
    sudo mv nvim-linux-x86_64 /usr/local/nvim
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/vim
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim
    vim -v
    ;;
"Linux-arm64" | "Linux-aarch64")
    cd /tmp
    rm -rf nvim-linux-arm64.tar.gz
    wget "https://github.com/neovim/neovim/releases/download/$ver/nvim-linux-arm64.tar.gz"
    tar zxf nvim-linux-arm64.tar.gz
    [ -e /usr/local/nvim ] && sudo mv -f /usr/local/nvim /usr/local/nvim-bak
    sudo mv nvim-linux-arm64 /usr/local/nvim
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/vim
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim
    vim -v
    ;;
*)
    echo "不支持的平台: $os_arch" >&2
    exit 1
    ;;
esac
