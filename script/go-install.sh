#!/bin/bash
set -e

# install gvm
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

# install gvm on fish
fish -c "fisher install JGAntunes/fish-gvm"
fish -c "fisher install edc/bass"

# install go
fish -c "gvm install -B go1.24.0"
fish -c "gvm use go1.24.0 --default"

# # install neovim
# os_arch=$(uname -s)-$(uname -m)

# case $os_arch in
#   "Darwin-x86_64")
# 	cd /usr/local
# 	wget https://golang.google.cn/dl/go1.23.2.linux-amd64.tar.gz
# 	tar zxvf go1.23.2.linux-amd64.tar.gz
# 	;;
#   "Linux-x86_64"|"Linux-arm64")
# 	cd /tmp
# 	rm -rf nvim-linux64.tar.gz
# 	wget https://go.dev/dl/go1.23.2.linux-amd64.tar.gz
# 	tar zxvf go1.23.2.linux-amd64.tar.gz
# 	mv go /usr/local/
# 	sudo ln -s /usr/local/go/bin/go/usr/local/bin/go
# 	;;
# esac
