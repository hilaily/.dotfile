#!/bin/bash

LOCAL_CONFIG="$HOME/.config/fish/config.fish"
DEFAULT_PATH="$HOME/.dotfile/fish/default.fish"
SOURCE_LINE="source $DEFAULT_PATH"

mkdir -p "$HOME/.config/fish"

echo 'Setup fish config.fish wrapper'

# 旧版迁移：如果 config.fish 是指向 dotfile 的 symlink（老布局），移除
if [ -L "$LOCAL_CONFIG" ]; then
    link_target=$(readlink "$LOCAL_CONFIG")
    case "$link_target" in
        */dotfile/fish/config.fish|*/dotfile/fish/default.fish)
            echo "  Removing legacy symlink: $LOCAL_CONFIG -> $link_target"
            rm "$LOCAL_CONFIG"
            ;;
    esac
fi

# 不存在 -> 创建只含一行 source 的本地 wrapper
# 存在但未 source default.fish -> 在文件顶部插入 source 行
# 已 source -> 跳过
if [ ! -f "$LOCAL_CONFIG" ]; then
    echo "$SOURCE_LINE" > "$LOCAL_CONFIG"
    echo "  Created $LOCAL_CONFIG (sources default.fish)"
elif ! grep -qE '^[[:space:]]*source.*default\.fish' "$LOCAL_CONFIG"; then
    tmp=$(mktemp)
    { echo "$SOURCE_LINE"; echo; cat "$LOCAL_CONFIG"; } > "$tmp"
    mv "$tmp" "$LOCAL_CONFIG"
    echo "  Prepended source line to existing $LOCAL_CONFIG"
else
    echo "  $LOCAL_CONFIG already sources default.fish, skip"
fi

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
