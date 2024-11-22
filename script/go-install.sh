#!/bin/bash
set -e

# install neovim
os_arch=$(uname -s)-$(uname -m)

case $os_arch in
  "Darwin-x86_64")
	cd /usr/local
	wget https://golang.google.cn/dl/go1.23.2.linux-amd64.tar.gz
	tar zxvf go1.23.2.linux-amd64.tar.gz 
	;;
  "Linux-x86_64"|"Linux-arm64")
	cd /tmp
	rm -rf nvim-linux64.tar.gz
	wget https://go.dev/dl/go1.23.2.linux-amd64.tar.gz
	tar zxvf go1.23.2.linux-amd64.tar.gz 
	mv go /usr/local/
	sudo ln -s /usr/local/go/bin/go/usr/local/bin/go
	;;
esac
        
	


