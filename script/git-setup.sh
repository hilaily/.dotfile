#!/bin/bash
# 交互式保存 Git HTTPS 凭据（主机、用户名、Token）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: git-setup

交互式输入 Git 主机、用户名、Token，写入系统凭据存储。
写入后 HTTPS 克隆与 push 无需再输入密码。

需已配置 Git 凭据 helper（如先运行 ff script git-init 链接 dotfile 配置）。
凭据由 ~/.dotfile/git/git-credential.sh 管理（Keychain / libsecret / store）。

示例主机: github.com、gitlab.com、gitee.com
也支持输入完整地址，如 https://github.com 或 git@github.com

可重复运行以添加或更新其他主机凭据。

选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

set -euo pipefail

if ! command -v git >/dev/null 2>&1; then
    echo "错误: 未找到 git，请先安装 Git"
    exit 1
fi

if [[ ! -t 0 ]]; then
    echo "错误: 请在交互式终端中运行此脚本"
    exit 1
fi

normalize_git_host() {
    local input="$1"
    input="${input#https://}"
    input="${input#http://}"
    input="${input#git@}"
    input="${input%%/*}"
    input="${input%/}"
    echo "$input"
}

trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
}

prompt_required() {
    local prompt="$1"
    local var_name="$2"
    local secret="${3:-}"
    local value=""

    while [[ -z "$value" ]]; do
        if [[ "$secret" == "secret" ]]; then
            read -rsp "$prompt: " value
            echo >&2
        else
            read -rp "$prompt: " value
        fi
        value="$(trim "$value")"
        if [[ -z "$value" ]]; then
            echo "不能为空，请重新输入。" >&2
        fi
    done

    printf -v "$var_name" '%s' "$value"
}

store_git_credential() {
    local host="$1"
    local username="$2"
    local token="$3"

    printf 'protocol=https\nhost=%s\nusername=%s\npassword=%s\n\n' \
        "$host" "$username" "$token" | git credential approve

    if [[ -f "$HOME/.git-credentials" ]]; then
        chmod 600 "$HOME/.git-credentials"
    fi
}

verify_git_credential() {
    local host="$1"
    local username="$2"
    local filled=""

    filled="$(printf 'protocol=https\nhost=%s\n\n' "$host" | git credential fill 2>/dev/null || true)"
    if [[ "$filled" == *$'\n'"username=$username"$'\n'* ]]; then
        return 0
    fi
    return 1
}

echo "=== 保存 Git HTTPS 凭据 ==="
echo "凭据将保存到系统钥匙串；若不可用则回退到 ~/.git-credentials。"
echo ""

prompt_required "Git 主机地址 (如 github.com)" GIT_HOST
GIT_HOST="$(normalize_git_host "$GIT_HOST")"

if [[ -z "$GIT_HOST" ]]; then
    echo "错误: 无法解析 Git 主机地址"
    exit 1
fi

prompt_required "用户名" GIT_USERNAME
prompt_required "Token" GIT_TOKEN secret

store_git_credential "$GIT_HOST" "$GIT_USERNAME" "$GIT_TOKEN"
unset GIT_TOKEN

echo ""
if verify_git_credential "$GIT_HOST" "$GIT_USERNAME"; then
    echo "✅ 凭据已保存: https://${GIT_USERNAME}@${GIT_HOST}"
else
    echo "✅ 凭据已写入: https://${GIT_USERNAME}@${GIT_HOST}"
    echo "提示: 部分凭据 helper 无法通过 fill 验证，但 clone/push 通常仍可用。"
fi

echo ""
echo "可尝试:"
echo "  git clone https://${GIT_HOST}/<owner>/<repo>.git"
echo "  git ls-remote https://${GIT_HOST}/<owner>/<repo>.git"
