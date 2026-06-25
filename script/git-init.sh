#!/bin/bash

echo 'Init git config'
src=$HOME/.gitconfig
if [ -f $src ]; then
  mv $src $src.bak
fi
ln -s $HOME/.dotfile/git/.gitconfig $src

chmod +x "$HOME/.dotfile/git/git-credential-linux.sh"

