#!/bin/bash
# 初始化 Fish：wrapper 配置、链接 functions/completions、安装 fisher/z

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: fish-init

1. 确保 ~/.config/fish/config.fish  source dotfile/fish/default.fish
2. 链接 dotfile 中 fish functions 与 completions
3. 安装 fisher、z 插件
4. 将默认 shell 设为 fish

选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

LOCAL_CONFIG="$HOME/.config/fish/config.fish"
DEFAULT_PATH="$HOME/.dotfile/fish/default.fish"
SOURCE_LINE="source $DEFAULT_PATH"

mkdir -p "$HOME/.config/fish"

echo 'Setup fish config.fish wrapper'

if [ -L "$LOCAL_CONFIG" ]; then
    link_target=$(readlink "$LOCAL_CONFIG")
    case "$link_target" in
        */dotfile/fish/config.fish | */dotfile/fish/default.fish)
            echo "  Removing legacy symlink: $LOCAL_CONFIG -> $link_target"
            rm "$LOCAL_CONFIG"
            ;;
    esac
fi

if [ ! -f "$LOCAL_CONFIG" ]; then
    echo "$SOURCE_LINE" >"$LOCAL_CONFIG"
    echo "  Created $LOCAL_CONFIG (sources default.fish)"
elif ! grep -qE '^[[:space:]]*source.*default\.fish' "$LOCAL_CONFIG"; then
    tmp=$(mktemp)
    { echo "$SOURCE_LINE"; echo; cat "$LOCAL_CONFIG"; } >"$tmp"
    mv "$tmp" "$LOCAL_CONFIG"
    echo "  Prepended source line to existing $LOCAL_CONFIG"
else
    echo "  $LOCAL_CONFIG already sources default.fish, skip"
fi

echo 'Link fish functions and completions'
mkdir -p "$HOME/.config/fish/functions"
mkdir -p "$HOME/.config/fish/completions"

for file in $HOME/.dotfile/fish/functions/*.fish; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        target="$HOME/.config/fish/functions/$filename"
        if [ -f "$target" ] && [ ! -L "$target" ]; then
            mv "$target" "$target.bak"
        fi
        ln -sf "$file" "$target"
        echo "  Linked: functions/$filename"
    fi
done

for file in $HOME/.dotfile/fish/completions/*.fish; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        target="$HOME/.config/fish/completions/$filename"
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
echo "$fishpath" | sudo tee -a /etc/shells
chsh -s "$fishpath"
