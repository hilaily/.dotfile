#!/bin/bash
# 安装 pyenv 并配置 Python 3.11.10 及常用包

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: python-install

1. 若未安装则安装 pyenv
2. 安装 Python 3.11.10 并设为 global
3. 升级 pip 并安装 ipython/jupyter 等常用包

选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

if ! command -v pyenv &>/dev/null; then
    echo -e "${RED}pyenv 未安装. 正在安装 pyenv...${NC}"
    curl https://pyenv.run | bash
    if [ -f ~/.config/fish/config.fish ]; then
        # shellcheck disable=SC1090
        source ~/.config/fish/config.fish 2>/dev/null || true
    fi
else
    echo -e "${GREEN}pyenv 已安装${NC}"
fi

python_version=3.11.10

echo -e "${GREEN}正在安装 Python $python_version...${NC}"
pyenv install "$python_version"
pyenv global "$python_version"

installed_version=$(python --version)
echo -e "${GREEN}Python 安装完成. 当前版本: $installed_version${NC}"

echo -e "${GREEN}正在安装一些常用的 Python 包...${NC}"
pip install --upgrade pip
pip install ipython jupyter notebook pandas numpy matplotlib scikit-learn

echo -e "${GREEN}Python 环境设置完成!${NC}"
