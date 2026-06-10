#!/bin/bash

set -e

detect_distro() {
    if [ ! -f /etc/os-release ]; then
        echo "[ERROR] 未检测到 /etc/os-release，无法识别系统"
        exit 1
    fi

    . /etc/os-release

    case "${ID:-}" in
    debian | ubuntu)
        DISTRO="${ID}"
        CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME:-$(lsb_release -cs 2>/dev/null)}}"
        ;;
    *)
        echo "[ERROR] 不支持的操作系统: ${ID:-未知}，仅支持 Debian 和 Ubuntu"
        exit 1
        ;;
    esac

    if [ -z "$CODENAME" ]; then
        echo "[ERROR] 无法确定系统代号"
        exit 1
    fi
}

remove_conflicting_packages() {
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
        sudo apt-get remove -y $pkg 2>/dev/null || true
    done
}

install_prerequisites() {
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
}

#################################################################
# 国内安装（使用清华镜像）
install_docker_cn() {
    local repo_base="https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/${DISTRO}"
    local keyring="/usr/share/keyrings/docker-archive-keyring.gpg"

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL "${repo_base}/gpg" | sudo gpg --dearmor -o "${keyring}"

    echo "deb [arch=$(dpkg --print-architecture) signed-by=${keyring}] ${repo_base} \
    ${CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo usermod -aG docker "$USER"
}

#################################################################
# 国外安装（使用官方源）
install_docker_intl() {
    local repo_base="https://download.docker.com/linux/${DISTRO}"
    local keyring="/etc/apt/keyrings/docker.asc"

    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL "${repo_base}/gpg" -o "${keyring}"
    sudo chmod a+r "${keyring}"

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=${keyring}] ${repo_base} \
        ${CODENAME} stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo usermod -aG docker "$USER"
}

detect_distro
remove_conflicting_packages
install_prerequisites

# 根据环境变量选择安装方式（须在函数定义之后调用）
if [ "$CN_REGION" = "1" ]; then
    echo "[INFO] 国内环境，使用清华镜像安装 Docker (${DISTRO}/${CODENAME})"
    install_docker_cn
else
    echo "[INFO] 国外环境，使用官方源安装 Docker (${DISTRO}/${CODENAME})"
    install_docker_intl
fi

echo "[INFO] Docker 安装完成，请重新登录或运行: source ~/.config/fish/config.fish"
