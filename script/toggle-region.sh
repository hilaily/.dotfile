#!/bin/bash
# 切换 CN_REGION 并持久化到 ~/.config/fish/custom.fish

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/region.sh"

usage() {
    cat <<'EOF'
用法: toggle-region

切换 CN_REGION 并写入 ~/.config/fish/custom.fish:
  1 -> 0  国内 -> 国外
  0/未设置 -> 1  国外 -> 国内

fish 中推荐: ff region
通过 ff script 调用后，当前 fish 会话会自动同步该变量。

选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

next="$(dotfile_region_toggle)"
echo "[INFO] Region switched to: ${next} ($(dotfile_region_label "$next"))"
echo "[INFO] 已写入 $(dotfile_region_custom_fish)"
