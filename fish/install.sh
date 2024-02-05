if [ -f "$HOME/.config/fish/config.fish" ]; then
  mv $HOME/.config/fish/config.fish $HOME/.config/fish/config.fish.bak
fi
ln -s $HOME/.dotfile/fish/config.fish $HOME/.config/fish/config.fish
