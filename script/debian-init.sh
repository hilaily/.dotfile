#!/bin/bash

# Debian 国内镜像源更换脚本
# 支持 Debian 9/10/11/12/13 (stretch/buster/bullseye/bookworm/trixie)

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检测是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}错误: 请使用 root 权限运行此脚本${NC}"
    echo "使用: sudo $0"
    exit 1
fi

# 检测 Debian 版本
detect_debian_version() {
    if [ -f /etc/debian_version ]; then
        DEBIAN_VERSION=$(cat /etc/debian_version | cut -d. -f1)
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            CODENAME=$(echo $VERSION_CODENAME | tr '[:upper:]' '[:lower:]')
        else
            case $DEBIAN_VERSION in
                9) CODENAME="stretch" ;;
                10) CODENAME="buster" ;;
                11) CODENAME="bullseye" ;;
                12) CODENAME="bookworm" ;;
                13) CODENAME="trixie" ;;
                *) CODENAME="bookworm" ;; # 默认使用 bookworm
            esac
        fi
    else
        echo -e "${RED}错误: 未检测到 Debian 系统${NC}"
        exit 1
    fi
}

# 显示可用的镜像源
show_mirrors() {
    echo -e "${YELLOW}可用的国内镜像源:${NC}"
    echo "1) 阿里云 (aliyun)"
    echo "2) 清华大学 (tsinghua)"
    echo "3) 中科大 (ustc)"
    echo "4) 网易 (163)"
    echo "5) 华为云 (huawei)"
    echo "6) 腾讯云 (tencent)"
}

# 获取镜像源 URL
get_mirror_url() {
    local mirror=$1
    local codename=$2
    
    case $mirror in
        aliyun)
            echo "https://mirrors.aliyun.com/debian/"
            ;;
        tsinghua)
            echo "https://mirrors.tuna.tsinghua.edu.cn/debian/"
            ;;
        ustc)
            echo "https://mirrors.ustc.edu.cn/debian/"
            ;;
        163)
            echo "https://mirrors.163.com/debian/"
            ;;
        huawei)
            echo "https://mirrors.huaweicloud.com/debian/"
            ;;
        tencent)
            echo "https://mirrors.cloud.tencent.com/debian/"
            ;;
        *)
            echo "https://mirrors.aliyun.com/debian/" # 默认使用阿里云
            ;;
    esac
}

# 获取安全更新镜像源 URL
get_security_mirror_url() {
    local mirror=$1
    
    case $mirror in
        aliyun)
            echo "https://mirrors.aliyun.com/debian-security/"
            ;;
        tsinghua)
            echo "https://mirrors.tuna.tsinghua.edu.cn/debian-security/"
            ;;
        ustc)
            echo "https://mirrors.ustc.edu.cn/debian-security/"
            ;;
        163)
            echo "https://mirrors.163.com/debian-security/"
            ;;
        huawei)
            echo "https://mirrors.huaweicloud.com/debian-security/"
            ;;
        tencent)
            echo "https://mirrors.cloud.tencent.com/debian-security/"
            ;;
        *)
            echo "https://mirrors.aliyun.com/debian-security/" # 默认使用阿里云
            ;;
    esac
}

# 生成 sources.list 内容
generate_sources_list() {
    local mirror_url=$1
    local security_mirror_url=$2
    local codename=$3
    
    cat <<EOF
# Debian ${codename} 国内镜像源
# 生成时间: $(date '+%Y-%m-%d %H:%M:%S')

# 默认仓库
deb ${mirror_url} ${codename} main contrib non-free non-free-firmware
deb ${mirror_url} ${codename}-updates main contrib non-free non-free-firmware
deb ${mirror_url} ${codename}-backports main contrib non-free non-free-firmware

# 安全更新
deb ${security_mirror_url} ${codename}-security main contrib non-free non-free-firmware

EOF
}

# 主函数
main() {
    echo -e "${GREEN}=== Debian 国内镜像源更换脚本 ===${NC}\n"
    
    # 检测 Debian 版本
    detect_debian_version
    echo -e "${GREEN}检测到 Debian 版本: ${DEBIAN_VERSION} (${CODENAME})${NC}\n"
    
    # 显示可用镜像源
    show_mirrors
    echo ""
    read -p "请选择镜像源 (1-6，默认 1): " choice
    choice=${choice:-1}
    
    case $choice in
        1) MIRROR="aliyun" ;;
        2) MIRROR="tsinghua" ;;
        3) MIRROR="ustc" ;;
        4) MIRROR="163" ;;
        5) MIRROR="huawei" ;;
        6) MIRROR="tencent" ;;
        *) MIRROR="aliyun" ;;
    esac
    
    MIRROR_URL=$(get_mirror_url $MIRROR $CODENAME)
    SECURITY_MIRROR_URL=$(get_security_mirror_url $MIRROR)
    echo -e "\n${GREEN}选择的镜像源: ${MIRROR} (${MIRROR_URL})${NC}"
    echo -e "${GREEN}安全更新镜像源: ${SECURITY_MIRROR_URL}${NC}\n"
    
    # 备份原有 sources.list
    SOURCES_LIST="/etc/apt/sources.list"
    BACKUP_FILE="/etc/apt/sources.list.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [ -f "$SOURCES_LIST" ]; then
        cp "$SOURCES_LIST" "$BACKUP_FILE"
        echo -e "${GREEN}已备份原有 sources.list 到: ${BACKUP_FILE}${NC}"
    fi
    
    # 生成新的 sources.list
    generate_sources_list "$MIRROR_URL" "$SECURITY_MIRROR_URL" "$CODENAME" > "$SOURCES_LIST"
    echo -e "${GREEN}已更新 sources.list${NC}\n"
    
    # 更新软件包列表
    echo -e "${YELLOW}正在更新软件包列表...${NC}"
    apt update
    
    echo -e "\n${GREEN}✓ 镜像源更换完成！${NC}"
    echo -e "${GREEN}备份文件位置: ${BACKUP_FILE}${NC}"
}

# 运行主函数
main

