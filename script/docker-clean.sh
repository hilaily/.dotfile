#!/bin/bash
# 清理 Docker 未使用的镜像、容器与缓存（docker system prune -a）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: docker-clean

执行 docker system prune -a，删除未使用的镜像、容器、网络等。

选项:
  -h, --help  显示此帮助

警告: 会删除未使用的镜像，请确认无重要 dangling 资源。
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

set -euo pipefail

docker system prune -a
