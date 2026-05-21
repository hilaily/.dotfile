#!/bin/bash

set -e

# install neovim
os_arch=$(uname -s)-$(uname -m)
ver=v0.12.2

case $os_arch in
"Darwin-x86_64")
    cd /tmp
    rm -rf nvim-macos-x86_64.tar.gz
    wget https://github.com/neovim/neovim/releases/download/$ver/nvim-macos-x86_64.tar.gz
    tar zxf nvim-macos-x86_64.tar.gz
    sudo mv -f /usr/local/nvim /usr/local/nvim-bak
    sudo mv nvim-macos-x86_64 /usr/local/nvim
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/vim
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim
    echo ""
    vim -v
    ;;
"Darwin-arm64" | "Darwin-aarch64")
    cd /tmp
    rm -rf nvim-macos-arm64.tar.gz
    wget https://github.com/neovim/neovim/releases/download/$ver/nvim-macos-arm64.tar.gz
    tar zxf nvim-macos-arm64.tar.gz
    [ -e /usr/local/nvim ] && sudo mv -f /usr/local/nvim /usr/local/nvim-bak
    sudo mv nvim-macos-arm64 /usr/local/nvim
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/vim
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim
    echo ""
    vim -v
    ;;
"Linux-x86_64")
    cd /tmp
    rm -rf nvim-linux64.tar.gz
    wget https://github.com/neovim/neovim/releases/download/$ver/nvim-linux-x86_64.tar.gz
    tar zxf nvim-linux-x86_64.tar.gz
    [ -e /usr/local/nvim ] && sudo mv -f /usr/local/nvim /usr/local/nvim-bak
    sudo mv nvim-linux-x86_64 /usr/local/nvim
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/vim
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim
    echo ""
    vim -v
    ;;
"Linux-arm64" | "Linux-aarch64")
    cd /tmp
    rm -rf nvim-linux64.tar.gz
    wget https://github.com/neovim/neovim/releases/download/$ver/nvim-linux-arm64.tar.gz
    tar zxf nvim-linux64.tar.gz
    [ -e /usr/local/nvim ] && sudo mv -f /usr/local/nvim /usr/local/nvim-bak
    sudo mv nvim-linux64 /usr/local/nvim
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/vim
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim
    echo ""
    vim -v
    ;;

*)
    echo "不支持的平台: $os_arch" >&2
    exit 1
    ;;
esac

# if has error "no c compile found"
# sudo apt install build-essential
