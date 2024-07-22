#/bin/bash

echo 'Init tmux config'
src=$HOME/.tmux.conf
if [ -e $src ]; then
  mv $src $src.bak
fi
ln -s $HOME/.dotfile/tmux/.tmux.conf $src


echo 'Install tpm'
if [ ! -e ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo 'Install tmux plugin by tpm'
$HOME/.tmux/plugins/tpm/bin/install_plugins

echo 'Reload tmux'
tmux source ~/.tmux.conf