#!/bin/bash

echo 'Link fish config file'
if [ -f "$HOME/.config/fish/config.fish" ]; then
  mv $HOME/.config/fish/config.fish $HOME/.config/fish/config.fish.bak
fi
ln -s $HOME/.dotfile/fish/config.fish $HOME/.config/fish/config.fish

echo 'Set fish as default shell'
fishpath=$(which fish)
echo $fishpath | sudo tee -a /etc/shells
chsh -s $fishpath

