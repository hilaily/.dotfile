#!/bin/bash
# 安装 mise 并链接 dotfile 配置、安装 config.toml 中的工具

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: mise-install

1. 若未安装则通过官方脚本安装 mise
2. 链接 ~/.dotfile/mise/config.toml
3. 执行 mise install 安装配置中的工具

选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

if ! command -v mise &>/dev/null; then
    echo -e "${YELLOW}mise 未安装. 正在安装 mise...${NC}"
    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"

    if [ -f ~/.config/fish/config.fish ]; then
        if ! grep -q "mise activate" ~/.config/fish/config.fish; then
            echo -e "${YELLOW}正在为 fish shell 配置 mise...${NC}"
            {
                echo ''
                echo '# mise (formerly rtx)'
                echo 'mise activate fish | source'
            } >>~/.config/fish/config.fish
            echo -e "${GREEN}已将 mise 添加到 ~/.config/fish/config.fish${NC}"
        fi
    fi

    echo -e "${GREEN}mise 安装完成${NC}"
else
    echo -e "${GREEN}mise 已安装${NC}"
    mise --version
fi

MISE_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mise"
DOTFILE_MISE_CONFIG="$HOME/.dotfile/mise/config.toml"
mkdir -p "$MISE_CONFIG_DIR"
if [ -f "$DOTFILE_MISE_CONFIG" ]; then
    if [ -f "$MISE_CONFIG_DIR/config.toml" ] && [ ! -L "$MISE_CONFIG_DIR/config.toml" ]; then
        mv "$MISE_CONFIG_DIR/config.toml" "$MISE_CONFIG_DIR/config.toml.bak"
        echo -e "${YELLOW}已备份原有配置到 config.toml.bak${NC}"
    fi
    ln -sf "$DOTFILE_MISE_CONFIG" "$MISE_CONFIG_DIR/config.toml"
    echo -e "${GREEN}已链接 mise 配置: $MISE_CONFIG_DIR/config.toml${NC}"
    mise trust "$DOTFILE_MISE_CONFIG" 2>/dev/null || true
fi

if command -v mise &>/dev/null && [ -f "$MISE_CONFIG_DIR/config.toml" ]; then
    echo -e "${YELLOW}正在安装 mise 工具...${NC}"
    mise install
    echo -e "${GREEN}mise 工具安装完成${NC}"
fi

if command -v mise &>/dev/null; then
    echo -e "${GREEN}mise 安装成功!${NC}"
else
    echo -e "${RED}mise 安装失败，请检查错误信息${NC}"
    exit 1
fi
