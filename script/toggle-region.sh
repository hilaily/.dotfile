#!/bin/bash
# 切换 CN_REGION 环境变量（国内/国外镜像与安装源）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: toggle-region

在当前 shell 中切换 CN_REGION:
  1 -> 0  国内 -> 国外
  0/未设置 -> 1  国外 -> 国内

影响依赖 CN_REGION 的安装脚本（如 docker-install）。

选项:
  -h, --help  显示此帮助

说明: 仅影响当前 shell 会话；持久化请写入 fish/zsh 配置。
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

if [ "$CN_REGION" = "1" ]; then
    export CN_REGION=0
    echo "[INFO] Region switched to: 0 (国外)"
else
    export CN_REGION=1
    echo "[INFO] Region switched to: 1 (国内)"
fi
