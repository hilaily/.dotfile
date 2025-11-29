#!/bin/bash
source ./script/common/os-arch.sh

# 检查并安装 gunzip
function check_gunzip() {
    if ! command -v gunzip &> /dev/null; then
        echo "gunzip 未安装，正在安装..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y gzip
        elif command -v yum &> /dev/null; then
            sudo yum install -y gzip
        elif command -v brew &> /dev/null; then
            brew install gzip
        else
            echo "错误: 无法安装 gunzip，请手动安装 gzip 工具"
            exit 1
        fi
    fi
}

function install_mihomo() {
    local os_arch=$(get_os_arch)
    local base_url="https://oss-default.yumee.top/bin/mihomo"
    local url=""
    
    # 根据不同平台设置下载 URL
    # 支持的平台示例:
    # darwin-amd64: https://oss-default.yumee.top/bin/mihomo/mihomo-darwin-amd64.gz
    # darwin-arm64: https://oss-default.yumee.top/bin/mihomo/mihomo-darwin-arm64.gz
    # linux-amd64:  https://oss-default.yumee.top/bin/mihomo/mihomo-linux-amd64.gz
    # linux-arm64:  https://oss-default.yumee.top/bin/mihomo/mihomo-linux-arm64.gz
    
    case $os_arch in
        "darwin-amd64"|"darwin-arm64"|"linux-amd64"|"linux-arm64")
            url="${base_url}/mihomo-${os_arch}.gz"
            echo "正在为 ${os_arch} 平台安装 mihomo..."
            ;;
        *)
            echo "错误: 不支持的平台 ${os_arch}"
            exit 1
            ;;
    esac
    
    # 检查 gunzip 命令
    check_gunzip
    
    # 创建临时目录
    local temp_dir=$(mktemp -d)
    local temp_file="${temp_dir}/mihomo.gz"
    
    # 下载文件
    echo "正在从 ${url} 下载..."
    if ! curl -L -o "${temp_file}" "${url}"; then
        echo "错误: 下载失败"
        rm -rf "${temp_dir}"
        exit 1
    fi
    
    # 解压文件
    echo "正在解压..."
    if ! gunzip "${temp_file}"; then
        echo "错误: 解压失败"
        rm -rf "${temp_dir}"
        exit 1
    fi
    
    # 移动到 /usr/local/bin 并设置执行权限
    local binary="${temp_dir}/mihomo"
    echo "正在安装到 /usr/local/bin/mihomo..."
    sudo mv "${binary}" /usr/local/bin/mihomo
    sudo chmod +x /usr/local/bin/mihomo
    
    # 清理临时文件
    rm -rf "${temp_dir}"
    
    echo "mihomo 安装完成!"
    echo "版本信息:"
    /usr/local/bin/mihomo version || echo "mihomo 已安装到 /usr/local/bin/mihomo"
}

install_mihomo