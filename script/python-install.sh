#!/bin/bash

set -e

# 设置颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查是否已安装 pyenv
if ! command -v pyenv &> /dev/null
then
    echo -e "${RED}pyenv 未安装. 正在安装 pyenv...${NC}"
    # 安装 pyenv
    curl https://pyenv.run | bash
    source ~/.config/fish/config.fish
else
    echo -e "${GREEN}pyenv 已安装${NC}"
fi

# 询问用户想安装的 Python 版本
python_version=3.11.10

# 安装指定版本的 Python
echo -e "${GREEN}正在安装 Python $python_version...${NC}"
pyenv install $python_version

# 设置全局 Python 版本
pyenv global $python_version

# 验证安装
installed_version=$(python --version)
echo -e "${GREEN}Python 安装完成. 当前版本: $installed_version${NC}"

# 安装一些常用的 Python 包
echo -e "${GREEN}正在安装一些常用的 Python 包...${NC}"
pip install --upgrade pip
pip install ipython jupyter notebook pandas numpy matplotlib scikit-learn

echo -e "${GREEN}Python 环境设置完成!${NC}"
