#!bin/sh
#git clone https://github.com/hilaily/.dotfile.git ~/.dotfile

# 判断 zsh 是否安装
#sudo yum update && sudo yum -y install zsh

# 判断 oh-my-zsh 是否安装
if [ ! -d "$HOME/.oh-my-zsh" ];then
    export ZSH=$HOME/.oh-my-zsh
    sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
fi
ln -sf ~/.dotfile/.zshrc ~/
ln -sf ~/.dotfile/laily.zsh-theme ~/.oh-my-zsh/themes/
ln -sf ~/.dotfile/.tmux.conf ~/
ln -sf ~/.dotfile/git/.gitconfig ~/.gitconfig

# install neovim
cd /usr/local
wget https://github.com/neovim/neovim/releases/download/v0.6.0/nvim-macos.tar.gz 
tar zxvf nvim-macos.tar.gz 
