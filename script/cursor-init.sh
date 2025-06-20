#!/bin/bash

echo 'Cursor config init'

# init settings.json
src="$HOME/Library/Application Support/Cursor/User/settings.json"
if [ -f "$src" ]; then
	mv "$src" "$src.bak"
fi
ln -s "$HOME/.dotfile/vscode/settings.json" "$src"

# init keybindings.json
src="$HOME/Library/Application Support/Cursor/User/keybindings.json"
if [ -f "$src" ]; then
	mv "$src" "$src.bak"
fi
ln -s "$HOME/.dotfile/vscode/keybindings.json" "$src"
