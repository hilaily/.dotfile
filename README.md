### 使用
```shell
git clone https://github.com/Laily123/.dotfile.git ~/.dotfile
```
### zsh 安装
安装 zsh  
```shell
https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH
# macOS
brew install zsh zsh-completions
# CentOS
sudo yum -y install zsh
# Ubuntu
apt install zsh
```

安装 oh-my-zsh  
```shell
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
```
初始化配置  
```shell
ln -sf ~/.dotfile/.zshrc ~/  
ln -sf ~/.dotfile/laily.zsh-theme ~/.oh-my-zsh/themes/
ln -sf ~/.dotfile/.tmux.conf ~/
ln -sf ~/.dotfile/.gitconfig ~/.gitconfig
```

### spacevim 安装
安装  
`curl -sLf https://spacevim.org/install.sh | bash`  
初始化配置  
`ln -sf ~/.dotfile/.SpaceVim.d ~/` 

