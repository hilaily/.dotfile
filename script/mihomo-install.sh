#!/bin/bash
# 下载并安装 mihomo 代理内核到 /usr/local/bin

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: mihomo-install

根据当前 OS/架构从镜像下载 mihomo 二进制，安装到 /usr/local/bin/mihomo。
支持 darwin/linux 的 amd64/arm64。

选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

source "$SCRIPT_DIR/common/os-arch.sh"

check_gunzip() {
    if ! command -v gunzip &>/dev/null; then
        echo "gunzip 未安装，正在安装..."
        if command -v apt-get &>/dev/null; then
            sudo apt-get update && sudo apt-get install -y gzip
        elif command -v yum &>/dev/null; then
            sudo yum install -y gzip
        elif command -v brew &>/dev/null; then
            brew install gzip
        else
            echo "错误: 无法安装 gunzip，请手动安装 gzip 工具"
            exit 1
        fi
    fi
}

install_mihomo() {
    local os_arch
    os_arch=$(get_os_arch)
    local base_url="https://oss-default.yumee.top/bin/mihomo"
    local url=""

    case $os_arch in
    "darwin-amd64" | "darwin-arm64" | "linux-amd64" | "linux-arm64")
        url="${base_url}/mihomo-${os_arch}.gz"
        echo "正在为 ${os_arch} 平台安装 mihomo..."
        ;;
    *)
        echo "错误: 不支持的平台 ${os_arch}"
        exit 1
        ;;
    esac

    check_gunzip

    local temp_dir
    temp_dir=$(mktemp -d)
    local temp_file="${temp_dir}/mihomo.gz"

    echo "正在从 ${url} 下载..."
    if ! curl -L -o "${temp_file}" "${url}"; then
        echo "错误: 下载失败"
        rm -rf "${temp_dir}"
        exit 1
    fi

    echo "正在解压..."
    if ! gunzip "${temp_file}"; then
        echo "错误: 解压失败"
        rm -rf "${temp_dir}"
        exit 1
    fi

    local binary="${temp_dir}/mihomo"
    echo "正在安装到 /usr/local/bin/mihomo..."
    sudo mv "${binary}" /usr/local/bin/mihomo
    sudo chmod +x /usr/local/bin/mihomo

    rm -rf "${temp_dir}"

    echo "mihomo 安装完成!"
    /usr/local/bin/mihomo version || echo "mihomo 已安装到 /usr/local/bin/mihomo"
}

install_mihomo
