#!/bin/bash
# 安装并初始化 Fish、tmux 与 Git 的基础 dotfile 环境

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/script/common/help.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/script/common/os-arch.sh"

set -euo pipefail

usage() {
    cat <<'EOF'
用法: ./init.sh

安装缺失的基础工具（fish、tmux、git），随后依次执行：
  1. fish-init  初始化 Fish 配置、插件与默认 shell
  2. tmux-init  初始化 tmux 配置与 TPM 插件
  3. git-init   初始化 Git 配置

支持:
  macOS        Homebrew
  Debian/Ubuntu apt

选项:
  -h, --help  显示此帮助

说明:
  请以需要配置的普通用户运行，不要使用 sudo 运行本脚本。
  Linux 安装缺失软件时会请求 sudo；Fish 初始化也会请求 sudo 将 fish
  加入 /etc/shells。
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help
[[ $# -eq 0 ]] || { echo "错误: 不支持参数: $*" >&2; usage >&2; exit 1; }

die() {
    echo "错误: $*" >&2
    exit 1
}

run_with_sudo() {
    if [[ $EUID -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

[[ $EUID -ne 0 ]] || die "请以需要配置的普通用户运行，不要使用 sudo ./init.sh"
[[ -d "$HOME/.dotfile" ]] || die "未找到 $HOME/.dotfile；请将仓库放在该路径后重试"
[[ "$SCRIPT_DIR" -ef "$HOME/.dotfile" ]] || die "当前仓库不是 $HOME/.dotfile；现有初始化脚本依赖该路径"

missing_packages=()
command -v fish >/dev/null 2>&1 || missing_packages+=(fish)
command -v tmux >/dev/null 2>&1 || missing_packages+=(tmux)
command -v git >/dev/null 2>&1 || missing_packages+=(git)

if ((${#missing_packages[@]} == 0)); then
    echo "基础工具已安装：fish、tmux、git"
else
    echo "安装缺失工具: ${missing_packages[*]}"
    case "$(get_os)" in
        darwin)
            command -v brew >/dev/null 2>&1 || die "未找到 Homebrew；请先运行: bash script/brew-install.sh"
            brew install "${missing_packages[@]}"
            ;;
        linux)
            command -v apt-get >/dev/null 2>&1 || die "仅支持 apt；请先通过系统包管理器安装: ${missing_packages[*]}"
            run_with_sudo apt-get update
            run_with_sudo apt-get install -y "${missing_packages[@]}"
            ;;
        *)
            die "不支持的系统: $(get_os)"
            ;;
    esac
fi

echo
echo "== 初始化 Fish =="
bash "$SCRIPT_DIR/script/fish-init.sh"

echo
echo "== 初始化 tmux =="
bash "$SCRIPT_DIR/script/tmux-init.sh"

echo
echo "== 初始化 Git =="
bash "$SCRIPT_DIR/script/git-init.sh"

echo
echo "基础环境初始化完成。重新打开终端后 Fish 将作为默认 shell 生效。"
