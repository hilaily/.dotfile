#!/bin/bash

echo 'Link fish config file'
# 备份并链接 config.fish
if [ -f "$HOME/.config/fish/config.fish" ] && [ ! -L "$HOME/.config/fish/config.fish" ]; then
    mv $HOME/.config/fish/config.fish $HOME/.config/fish/config.fish.bak
fi
ln -sf $HOME/.dotfile/fish/config.fish $HOME/.config/fish/config.fish

# 确保目标目录存在
echo 'Link fish functions and completions'
mkdir -p "$HOME/.config/fish/functions"
mkdir -p "$HOME/.config/fish/completions"

# 链接 functions 目录下的所有文件
for file in $HOME/.dotfile/fish/functions/*.fish; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        target="$HOME/.config/fish/functions/$filename"
        # 如果已存在且不是符号链接，备份
        if [ -f "$target" ] && [ ! -L "$target" ]; then
            mv "$target" "$target.bak"
        fi
        ln -sf "$file" "$target"
        echo "  Linked: functions/$filename"
    fi
done

# 链接 completions 目录下的所有文件
for file in $HOME/.dotfile/fish/completions/*.fish; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        target="$HOME/.config/fish/completions/$filename"
        # 如果已存在且不是符号链接，备份
        if [ -f "$target" ] && [ ! -L "$target" ]; then
            mv "$target" "$target.bak"
        fi
        ln -sf "$file" "$target"
        echo "  Linked: completions/$filename"
    fi
done

fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fish -c "fisher install jethrokuan/z"

echo 'Set fish as default shell'
fishpath=$(which fish)
echo $fishpath | sudo tee -a /etc/shells
chsh -s $fishpath
