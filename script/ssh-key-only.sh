#!/bin/bash
# 验证已有公钥后关闭 SSH 密码登录，仅保留公钥认证

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/os-arch.sh"

set -euo pipefail

usage() {
    cat <<'EOF'
用法: sudo ssh-key-only [--user <用户名>] [--yes]

在确认目标用户已有 SSH 公钥后，写入 /etc/ssh/sshd_config.d/99-dotfile-key-only.conf：
  PubkeyAuthentication yes
  PasswordAuthentication no
  KbdInteractiveAuthentication no
  ChallengeResponseAuthentication no

选项:
  -u, --user <用户名>  要确认公钥的用户；默认使用调用 sudo 前的用户
  -y, --yes            跳过交互确认
  -h, --help           显示此帮助

示例:
  sudo ssh-key-only
  sudo ssh-key-only --user deploy

重要说明:
  - 仅支持使用 systemd 管理 SSH 服务的 Linux 服务器。
  - 脚本不会创建 SSH 密钥；目标用户的 ~/.ssh/authorized_keys 中必须已有有效公钥。
  - 写入前会校验 sshd 配置，且重载后会再次核对生效设置；失败会恢复原文件。
  - 请保持当前 SSH 会话不要退出，另开一个终端验证密钥登录成功后再关闭。
EOF
}

TARGET_USER="${SUDO_USER:-}"
ASSUME_YES=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            dotfile_show_help
            ;;
        -u|--user)
            [[ $# -ge 2 ]] || { echo "错误: $1 需要用户名" >&2; exit 1; }
            TARGET_USER="$2"
            shift 2
            ;;
        -y|--yes)
            ASSUME_YES=1
            shift
            ;;
        *)
            echo "错误: 不支持参数: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

die() {
    echo "错误: $*" >&2
    exit 1
}

find_sshd() {
    local candidate
    if command -v sshd >/dev/null 2>&1; then
        command -v sshd
        return
    fi

    for candidate in /usr/sbin/sshd /usr/local/sbin/sshd; do
        [[ -x "$candidate" ]] && { printf '%s\n' "$candidate"; return; }
    done
}

user_home() {
    local user="$1" home
    if command -v getent >/dev/null 2>&1; then
        home=$(getent passwd "$user" | awk -F: 'NR == 1 {print $6}')
    fi
    printf '%s' "${home:-}"
}

setting_value() {
    local setting="$1"
    printf '%s\n' "$EFFECTIVE_CONFIG" | awk -v key="$setting" '$1 == key {print $2; exit}'
}

check_ssh_path_permissions() {
    local path="$1" owner mode
    owner=$(stat -c '%U' "$path")
    mode=$(stat -c '%a' "$path")

    [[ "$owner" == "$TARGET_USER" || "$owner" == "root" ]] || die "$path 的属主为 $owner，应为 $TARGET_USER 或 root"
    (( (8#$mode & 022) == 0 )) || die "$path 对组或其他用户可写（权限: $mode），sshd 可能会忽略其中的公钥"
}

config_is_key_only() {
    EFFECTIVE_CONFIG=$("$SSHD_BIN" -T -f "$SSHD_CONFIG" 2>/dev/null || true)
    [[ "$(setting_value pubkeyauthentication)" == "yes" ]] || return 1
    [[ "$(setting_value passwordauthentication)" == "no" ]] || return 1
    [[ "$(setting_value kbdinteractiveauthentication)" == "no" ]] || return 1
}

reload_sshd() {
    local unit
    for unit in ssh sshd; do
        if systemctl reload "$unit" >/dev/null 2>&1; then
            return 0
        fi
    done
    return 1
}

if [[ $EUID -ne 0 ]]; then
    die "请使用 sudo 运行，例如: sudo $0${TARGET_USER:+ --user "$TARGET_USER"}"
fi

[[ "$(get_os)" == "linux" ]] || die "当前仅支持 systemd 管理 SSH 服务的 Linux 服务器"
command -v systemctl >/dev/null 2>&1 || die "未找到 systemctl，无法安全重载 SSH 服务"
[[ -n "$TARGET_USER" ]] || die "无法识别目标用户；请指定 --user <用户名>"
id "$TARGET_USER" >/dev/null 2>&1 || die "用户不存在: $TARGET_USER"

TARGET_HOME=$(user_home "$TARGET_USER")
[[ -n "$TARGET_HOME" && -d "$TARGET_HOME" ]] || die "无法确定用户主目录: $TARGET_USER"
AUTHORIZED_KEYS="$TARGET_HOME/.ssh/authorized_keys"
[[ -r "$AUTHORIZED_KEYS" ]] || die "未找到可读取的公钥文件: $AUTHORIZED_KEYS"
[[ -d "$TARGET_HOME/.ssh" ]] || die "未找到 SSH 配置目录: $TARGET_HOME/.ssh"
check_ssh_path_permissions "$TARGET_HOME"
check_ssh_path_permissions "$TARGET_HOME/.ssh"
check_ssh_path_permissions "$AUTHORIZED_KEYS"

if ! grep -Eq '^[[:space:]]*(ssh-(rsa|ed25519|dss)|ecdsa-sha2-nistp(256|384|521)|sk-ssh-ed25519@openssh\.com|sk-ecdsa-sha2-nistp256@openssh\.com|[[:alnum:]_-]+-cert-v01@openssh\.com)[[:space:]]+' "$AUTHORIZED_KEYS"; then
    die "$AUTHORIZED_KEYS 中未发现有效的 SSH 公钥，已取消以避免锁定访问"
fi

SSHD_BIN=$(find_sshd)
[[ -n "$SSHD_BIN" ]] || die "未找到 sshd"
SSHD_CONFIG=/etc/ssh/sshd_config
[[ -r "$SSHD_CONFIG" ]] || die "无法读取 $SSHD_CONFIG"

if ! grep -Eq '^[[:space:]]*Include[[:space:]].*sshd_config\.d' "$SSHD_CONFIG"; then
    die "$SSHD_CONFIG 未包含 sshd_config.d；为避免覆盖现有规则，未作修改"
fi

DROP_IN_DIR=/etc/ssh/sshd_config.d
DROP_IN="$DROP_IN_DIR/99-dotfile-key-only.conf"
mkdir -p "$DROP_IN_DIR"

echo "将为 SSH 启用公钥认证，并关闭密码与交互式认证。"
echo "已确认 $TARGET_USER 的公钥文件: $AUTHORIZED_KEYS"
echo "配置文件: $DROP_IN"
if [[ $ASSUME_YES -ne 1 ]]; then
    read -r -p "确认继续？[y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || { echo "已取消，未修改配置。"; exit 0; }
fi

STAMP=$(date +%Y%m%d%H%M%S)
BACKUP=""
if [[ -f "$DROP_IN" ]]; then
    BACKUP="${DROP_IN}.bak.${STAMP}"
    cp -p "$DROP_IN" "$BACKUP"
fi

TMP_FILE=$(mktemp "${DROP_IN}.tmp.XXXXXX")
VALIDATION_ERROR=$(mktemp)
trap 'rm -f "$TMP_FILE" "$VALIDATION_ERROR"' EXIT

cat >"$TMP_FILE" <<'EOF'
# Managed by ~/.dotfile/script/ssh-key-only.sh
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
EOF
install -m 0600 -o root -g root "$TMP_FILE" "$DROP_IN"

restore_drop_in() {
    if [[ -n "$BACKUP" ]]; then
        cp -p "$BACKUP" "$DROP_IN"
    else
        rm -f "$DROP_IN"
    fi
}

if ! "$SSHD_BIN" -t -f "$SSHD_CONFIG" 2>"$VALIDATION_ERROR"; then
    restore_drop_in
    echo "sshd 配置校验输出：" >&2
    cat "$VALIDATION_ERROR" >&2
    die "新配置未通过校验，已恢复原文件"
fi

if ! config_is_key_only; then
    restore_drop_in
    die "新配置未成为 sshd 的生效设置（可能被更早的配置覆盖），已恢复原文件"
fi

if ! reload_sshd; then
    restore_drop_in
    die "无法重载 ssh/sshd 服务，已恢复原文件；请检查 systemctl 状态"
fi

if ! config_is_key_only; then
    restore_drop_in
    reload_sshd || true
    die "重载后设置未生效，已恢复原文件并尝试重载旧配置"
fi

echo "已启用仅公钥 SSH 登录。"
[[ -n "$BACKUP" ]] && echo "原配置已备份到: $BACKUP"
echo "请保持当前会话，另开终端确认可通过密钥登录后再退出。"
