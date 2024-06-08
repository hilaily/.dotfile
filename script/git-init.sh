#!/bin/bash

echo 'Init git config'
src=$HOME/.gitconfig
if [ -f $src ]; then
  mv $src $src.bak
fi
ln -s $HOME/.dotfile/git/.gitconfig $src

