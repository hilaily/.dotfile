#!/bin/bash

echo 'Link fish config file'
if [ -f "$HOME/.config/fish/config.fish" ]; then
    mv $HOME/.config/fish/config.fish $HOME/.config/fish/config.fish.bak
fi
ln -s $HOME/.dotfile/fish/config.fish $HOME/.config/fish/config.fish

fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fish -c "fisher install jethrokuan/z"

echo 'Set fish as default shell'
fishpath=$(which fish)
echo $fishpath | sudo tee -a /etc/shells
chsh -s $fishpath
