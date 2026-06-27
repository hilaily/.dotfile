#!/bin/bash
# 在 Debian/Ubuntu 上安装 Docker CE（支持国内/国外镜像源）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: docker-install

在 Debian 或 Ubuntu 上安装 Docker CE 及 compose/buildx 插件。
根据环境变量 CN_REGION 选择镜像源:
  CN_REGION=1  清华镜像
  其他         Docker 官方源

安装完成后将当前用户加入 docker 组。

选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

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

add_user_to_docker_group() {
    local target_user="${SUDO_USER:-$USER}"
    if [ -z "$target_user" ] || [ "$target_user" = "root" ]; then
        echo "[WARN] 无法确定目标用户，请手动执行: sudo docker-group <user>"
        return 0
    fi

    if ! getent group docker >/dev/null 2>&1; then
        echo "[WARN] docker 组不存在，跳过加组"
        return 0
    fi

    if id -nG "$target_user" | tr ' ' '\n' | grep -qx docker; then
        echo "[INFO] 用户 ${target_user} 已在 docker 组中"
        return 0
    fi

    sudo usermod -aG docker "$target_user"
    if id -nG "$target_user" | tr ' ' '\n' | grep -qx docker; then
        echo "[INFO] 已将 ${target_user} 加入 docker 组（需重新登录或 newgrp 后当前 shell 才生效）"
    else
        echo "[WARN] usermod 已执行，但未检测到 ${target_user} 在 docker 组中，请检查: getent group docker"
    fi
}

install_docker_cn() {
    local repo_base="https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/${DISTRO}"
    local keyring="/usr/share/keyrings/docker-archive-keyring.gpg"

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL "${repo_base}/gpg" | sudo gpg --dearmor -o "${keyring}"

    echo "deb [arch=$(dpkg --print-architecture) signed-by=${keyring}] ${repo_base} \
    ${CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    add_user_to_docker_group
}

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

    add_user_to_docker_group
}

detect_distro
remove_conflicting_packages
install_prerequisites

if [ "$CN_REGION" = "1" ]; then
    echo "[INFO] 国内环境，使用清华镜像安装 Docker (${DISTRO}/${CODENAME})"
    install_docker_cn
else
    echo "[INFO] 国外环境，使用官方源安装 Docker (${DISTRO}/${CODENAME})"
    install_docker_intl
fi

echo "[INFO] Docker 安装完成"
echo "[INFO] 若 docker 报 permission denied，组变更需新开登录会话才生效，任选其一:"
echo "       newgrp docker"
echo "       或重新 SSH 登录 / 重开终端"
echo "       验证: id -nG \$USER | tr ' ' '\\n' | grep -x docker"
