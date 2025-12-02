#!/bin/bash

echo 'Cursor config init'

# init settings.json
src="$HOME/Library/Application Support/Cursor/User/settings.json"
if [ -f "$src" ]; then
	mv "$src" "$src.bak"
fi
ln -s "$HOME/.dotfile/cursor/config/settings.json" "$src"

# init keybindings.json
src="$HOME/Library/Application Support/Cursor/User/keybindings.json"
if [ -f "$src" ]; then
	mv "$src" "$src.bak"
fi
ln -s "$HOME/.dotfile/cursor/config/keybindings.json" "$src"
