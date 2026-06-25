#!/bin/bash
# 将用户加入 docker 组（免 sudo 使用 docker）
# 用法: sudo docker-group <user>
# 示例: sudo docker-group xuser

set -euo pipefail

usage() {
    cat <<'EOF'
用法: sudo docker-group <user>

将 <user> 加入 docker 组，之后可直接运行 docker（无需 sudo）。

示例:
  sudo docker-group xuser

说明:
  - 用户需重新登录或 newgrp docker 后生效
  - 安装 Docker 时 docker-install.sh 只会把当时的 $USER 加入组
EOF
    exit 1
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage
[[ $# -eq 1 ]] || usage

if [[ $EUID -ne 0 ]]; then
    echo "错误: 请使用 sudo 运行，例如: sudo $0 $1"
    exit 1
fi

user="$1"

if ! id "$user" &>/dev/null; then
    echo "错误: 用户不存在: $user"
    exit 1
fi

if ! getent group docker &>/dev/null; then
    echo "错误: docker 组不存在，请先安装 Docker（例如运行 docker-install.sh）"
    exit 1
fi

if id -nG "$user" | tr ' ' '\n' | grep -qx docker; then
    echo "用户 $user 已在 docker 组中"
    exit 0
fi

usermod -aG docker "$user"
echo "已将 $user 加入 docker 组"
echo "请让用户重新登录，或执行: su - $user -c 'newgrp docker'"
