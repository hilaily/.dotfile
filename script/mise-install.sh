#!/bin/bash

set -e

# 设置颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否已安装 mise
if ! command -v mise &> /dev/null
then
    echo -e "${YELLOW}mise 未安装. 正在安装 mise...${NC}"
    # 安装 mise（官方安装脚本会自动配置 shell）
    curl https://mise.run | sh
    
    # 重新加载当前 shell 环境
    export PATH="$HOME/.local/bin:$PATH"
    
    # 如果安装脚本没有自动配置，手动配置 fish shell（如果存在）
    if [ -f ~/.config/fish/config.fish ]; then
        if ! grep -q "mise activate" ~/.config/fish/config.fish; then
            echo -e "${YELLOW}正在为 fish shell 配置 mise...${NC}"
            echo '' >> ~/.config/fish/config.fish
            echo '# mise (formerly rtx)' >> ~/.config/fish/config.fish
            echo 'mise activate fish | source' >> ~/.config/fish/config.fish
            echo -e "${GREEN}已将 mise 添加到 ~/.config/fish/config.fish${NC}"
        fi
    fi
    
    echo -e "${GREEN}mise 安装完成${NC}"
else
    echo -e "${GREEN}mise 已安装${NC}"
    mise --version
fi

# 验证安装
if command -v mise &> /dev/null
then
    echo -e "${GREEN}mise 安装成功!${NC}"
    echo -e "${YELLOW}提示: 如果 mise 命令不可用，请重新打开终端或运行:${NC}"
    echo -e "${GREEN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    echo -e "${YELLOW}或者重新加载 shell 配置文件${NC}"
else
    echo -e "${RED}mise 安装失败，请检查错误信息${NC}"
    exit 1
fi

