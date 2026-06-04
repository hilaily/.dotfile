#!/bin/bash

# Debian 一键更换清华镜像源脚本 (DEB822 格式)
# 支持 Debian 12 (bookworm)、13 (trixie)、14 (forky) 及后续版本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TUNA_DEBIAN="https://mirrors.tuna.tsinghua.edu.cn/debian"
SECURITY_DEBIAN="https://security.debian.org/debian-security"
KEYRING="/usr/share/keyrings/debian-archive-keyring.gpg"
SOURCES_FILE="/etc/apt/sources.list.d/debian.sources"
LEGACY_LIST="/etc/apt/sources.list"

# 检测是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误: 请使用 root 权限运行此脚本${NC}"
    echo "使用: sudo $0"
    exit 1
fi

# 检测 Debian 版本与代号
detect_debian() {
    if [ ! -f /etc/os-release ]; then
        echo -e "${RED}错误: 未检测到 /etc/os-release，无法识别系统${NC}"
        exit 1
    fi

    . /etc/os-release

    if [ "${ID:-}" != "debian" ]; then
        echo -e "${YELLOW}警告: 当前系统 ID 为 '${ID:-未知}'，并非纯 Debian，继续操作可能不适用${NC}"
    fi

    DEBIAN_VERSION=${VERSION_ID:-$(cut -d. -f1 /etc/debian_version 2>/dev/null)}
    CODENAME=$(echo "${VERSION_CODENAME:-}" | tr '[:upper:]' '[:lower:]')

    # 若 os-release 未提供代号，按主版本号兜底推断
    if [ -z "$CODENAME" ]; then
        case "${DEBIAN_VERSION%%.*}" in
        12) CODENAME="bookworm" ;;
        13) CODENAME="trixie" ;;
        14) CODENAME="forky" ;;
        *)
            echo -e "${RED}错误: 无法确定 Debian 代号 (版本: ${DEBIAN_VERSION:-未知})${NC}"
            exit 1
            ;;
        esac
    fi

    case "${DEBIAN_VERSION%%.*}" in
    12 | 13 | 14) ;;
    *)
        echo -e "${YELLOW}警告: 当前 Debian 主版本为 '${DEBIAN_VERSION%%.*}'，脚本主要面向 12/13/14，仍将按代号 '${CODENAME}' 生成配置${NC}"
        ;;
    esac
}

# 生成 DEB822 格式的 .sources 内容
generate_sources() {
    cat <<EOF
Types: deb
URIs: ${TUNA_DEBIAN}
Suites: ${CODENAME} ${CODENAME}-updates ${CODENAME}-backports
Components: main contrib non-free non-free-firmware
Signed-By: ${KEYRING}

# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
# Types: deb-src
# URIs: ${TUNA_DEBIAN}
# Suites: ${CODENAME} ${CODENAME}-updates ${CODENAME}-backports
# Components: main contrib non-free non-free-firmware
# Signed-By: ${KEYRING}

# 以下安全更新软件源为官方源配置
Types: deb
URIs: ${SECURITY_DEBIAN}
Suites: ${CODENAME}-security
Components: main contrib non-free non-free-firmware
Signed-By: ${KEYRING}

# Types: deb-src
# URIs: ${SECURITY_DEBIAN}
# Suites: ${CODENAME}-security
# Components: main contrib non-free non-free-firmware
# Signed-By: ${KEYRING}
EOF
}

main() {
    echo -e "${GREEN}=== Debian 一键更换清华镜像源 (DEB822) ===${NC}\n"

    detect_debian
    echo -e "${GREEN}检测到 Debian ${DEBIAN_VERSION} (${CODENAME})${NC}\n"

    local stamp
    stamp=$(date +%Y%m%d_%H%M%S)

    # 备份并停用旧版 sources.list，避免与 DEB822 配置重复
    if [ -s "$LEGACY_LIST" ]; then
        cp "$LEGACY_LIST" "${LEGACY_LIST}.backup.${stamp}"
        : >"$LEGACY_LIST"
        echo -e "${GREEN}已备份并清空旧版 sources.list -> ${LEGACY_LIST}.backup.${stamp}${NC}"
    fi

    # 备份已有的 .sources 文件
    if [ -f "$SOURCES_FILE" ]; then
        cp "$SOURCES_FILE" "${SOURCES_FILE}.backup.${stamp}"
        echo -e "${GREEN}已备份原有 debian.sources -> ${SOURCES_FILE}.backup.${stamp}${NC}"
    fi

    mkdir -p "$(dirname "$SOURCES_FILE")"
    generate_sources >"$SOURCES_FILE"
    echo -e "${GREEN}已写入清华镜像源配置 -> ${SOURCES_FILE}${NC}\n"

    echo -e "${YELLOW}正在更新软件包列表...${NC}"
    apt update

    echo -e "\n${GREEN}✓ 清华镜像源更换完成！${NC}"
}

main
