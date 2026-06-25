#!/bin/bash
# 为指定用户配置某命令的免密 sudo（写入 /etc/sudoers.d/）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

set -euo pipefail

usage() {
    cat <<'EOF'
用法: sudo nosudo <user> <command>

为 <user> 配置对 <command> 的免密 sudo（NOPASSWD）。

示例:
  sudo nosudo xuser docker
  sudo nosudo xuser /usr/bin/systemctl

说明:
  - 每个命令单独一个文件（nosudo-<user>-<命令名>），可多次执行、互不覆盖
    例如 nosudo xuser kubectl 与 nosudo xuser helm 会各写一条规则，同时生效
  - 仅允许免密执行解析到的那个可执行文件路径（含子命令参数仍受 sudo 规则约束）
  - 对 docker，更推荐: sudo docker-group <user>（无需 sudo 即可用 docker）
  - 删除规则: sudo rm /etc/sudoers.d/nosudo-<user>-<name>

选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help
[[ $# -eq 2 ]] || { usage; exit 1; }

if [[ $EUID -ne 0 ]]; then
    echo "错误: 请使用 sudo 运行，例如: sudo $0 $*"
    exit 1
fi

if [[ ! -d /etc/sudoers.d ]]; then
    echo "错误: 未找到 /etc/sudoers.d（当前系统可能不支持此方式）"
    exit 1
fi

user="$1"
cmd="$2"

if ! id "$user" &>/dev/null; then
    echo "错误: 用户不存在: $user"
    exit 1
fi

if [[ "$cmd" == /* ]]; then
    cmd_path="$cmd"
else
    cmd_path="$(command -v "$cmd" 2>/dev/null || true)"
fi

if [[ -z "$cmd_path" || ! -x "$cmd_path" ]]; then
    echo "错误: 找不到可执行文件: $cmd"
    echo "提示: 可先安装该命令，或传入绝对路径，例如 /usr/bin/docker"
    exit 1
fi

name="$(basename "$cmd_path")"
file="/etc/sudoers.d/nosudo-${user}-${name}"

if [[ -f "$file" ]]; then
  if grep -qF "NOPASSWD: ${cmd_path}" "$file" 2>/dev/null; then
    echo "已存在相同规则: $file"
    exit 0
  fi
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

cat >"$tmp" <<EOF
# Managed by nosudo ($0)
# user=$user command=$cmd_path
${user} ALL=(ALL) NOPASSWD: ${cmd_path}
EOF

if ! visudo -cf "$tmp" >/dev/null; then
    echo "错误: sudoers 语法校验失败"
    visudo -cf "$tmp" || true
    exit 1
fi

install -m 0440 -o root -g root "$tmp" "$file"

echo "已写入: $file"
echo "内容: ${user} ALL=(ALL) NOPASSWD: ${cmd_path}"
echo ""
echo "验证（切换到该用户后）:"
echo "  sudo -u ${user} sudo -n ${cmd_path} version 2>/dev/null || sudo -u ${user} sudo -n ${cmd_path} --help | head -1"
if [[ "$name" == "docker" ]]; then
    echo ""
    echo "提示: 若希望直接运行 docker（不用 sudo），请执行:"
    echo "  sudo docker-group ${user}"
fi
