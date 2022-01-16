#!bin/sh
#git clone https://github.com/Laily123/.dotfile.git ~/.dotfile
export ZSH=$HOME/.oh-my-zsh
#sudo yum update && sudo yum -y install zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
ln -sf ~/.dotfile/.zshrc ~/
ln -sf ~/.dotfile/laily.zsh-theme ~/.oh-my-zsh/themes/
ln -sf ~/.dotfile/.tmux.conf ~/
ln -sf ~/.dotfile/.gitconfig ~/.gitconfig

# install neovim
cd /usr/local
wget https://github.com/neovim/neovim/releases/download/v0.6.0/nvim-macos.tar.gz 
tar zxvf nvim-macos.tar.gz 
