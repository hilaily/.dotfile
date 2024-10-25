#!/bin/bash

# install neovim
os_arch=$(uname -s)-$(uname -m)

case $os_arch in
  "Darwin-x86_64")
	cd /usr/local
	wget https://github.com/neovim/neovim/releases/download/stable/nvim-macos.tar.gz
	tar zxvf nvim-macos.tar.gz 
	;;
  "Linux-x86_64"|"Linux-arm64")
	cd /tmp
	rm -rf nvim-linux64.tar.gz
	wget https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz
        tar zxf nvim-linux64.tar.gz
	sudo mv nvim-linux64 /usr/local/nvim
	sudo ln -s /usr/local/nvim/bin/nvim /usr/local/bin/vim
	;;
esac
        
	


