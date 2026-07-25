#!/bin/bash
# 验证已有公钥后关闭 SSH 密码和 root 登录，并改用 55522 端口

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/os-arch.sh"

set -euo pipefail

usage() {
    cat <<'EOF'
用法: sudo ssh-harden [--user <用户名>] [--skip-key-check] [--yes]

默认在确认目标用户已有 SSH 公钥后，直接更新 /etc/ssh/sshd_config 的全局配置：
  PubkeyAuthentication yes
  PasswordAuthentication no
  KbdInteractiveAuthentication no
  PermitRootLogin no
  Port 55522

选项:
  -u, --user <用户名>      要确认公钥的用户；默认使用调用 sudo 前的用户
  -k, --skip-key-check     跳过本地 authorized_keys 与权限检查
  -y, --yes                 跳过交互确认
  -h, --help                显示此帮助

示例:
  sudo ssh-harden
  sudo ssh-harden --user deploy
  sudo ssh-harden -k

重要说明:
  - 仅支持使用 systemd 管理 SSH 服务的 Linux 服务器。
  - 脚本不会创建 SSH 密钥；目标用户的 ~/.ssh/authorized_keys 中必须已有有效公钥。
  - 使用 -k/--skip-key-check 时，必须已有其他已验证的登录方式（例如 Tailscale SSH
    或云控制台）；该选项仅跳过本地 authorized_keys 检查。
  - 写入前会备份并校验 sshd_config，且重载后会再次核对生效设置；失败会恢复原文件。
  - 若 UFW 已启用，脚本会自动放行 TCP 55522；云安全组和其他防火墙仍需自行放行。
  - 请保持当前 SSH 会话不要退出，另开一个终端验证密钥登录成功后再关闭。
EOF
}

TARGET_USER="${SUDO_USER:-}"
ASSUME_YES=0
SSH_PORT=55522
UFW_RULE_ADDED=0
SKIP_KEY_CHECK=0

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
        -k|--skip-key-check)
            SKIP_KEY_CHECK=1
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

config_is_hardened() {
    local ports
    EFFECTIVE_CONFIG=$("$SSHD_BIN" -T -f "$SSHD_CONFIG" 2>/dev/null || true)
    [[ "$(setting_value pubkeyauthentication)" == "yes" ]] || return 1
    [[ "$(setting_value passwordauthentication)" == "no" ]] || return 1
    [[ "$(setting_value kbdinteractiveauthentication)" == "no" ]] || return 1
    [[ "$(setting_value permitrootlogin)" == "no" ]] || return 1
    ports=$(printf '%s\n' "$EFFECTIVE_CONFIG" | awk '$1 == "port" {print $2}')
    [[ "$ports" == "$SSH_PORT" ]] || return 1
}

port_is_in_use() {
    if command -v ss >/dev/null 2>&1; then
        ss -H -ltn "sport = :$SSH_PORT" 2>/dev/null | grep -q .
        return
    fi
    if command -v netstat >/dev/null 2>&1; then
        netstat -ltn 2>/dev/null | grep -Eq "[.:]${SSH_PORT}[[:space:]]"
        return
    fi
    return 1
}

sshd_already_uses_port() {
    local current_config
    current_config=$("$SSHD_BIN" -T -f "$SSHD_CONFIG" 2>/dev/null || true)
    printf '%s\n' "$current_config" | awk -v port="$SSH_PORT" '$1 == "port" && $2 == port {found = 1} END {exit !found}'
}

ensure_ufw_port() {
    local status
    if ! command -v ufw >/dev/null 2>&1; then
        echo "未安装 UFW，跳过防火墙规则修改。"
        return 0
    fi

    status=$(ufw status 2>&1)
    if ! printf '%s\n' "$status" | grep -qi '^Status: active'; then
        echo "UFW 未启用，跳过防火墙规则修改。"
        return 0
    fi

    if printf '%s\n' "$status" | grep -Eq "^[[:space:]]*${SSH_PORT}(/tcp)?[[:space:]]"; then
        echo "UFW 已有 TCP $SSH_PORT 规则，跳过。"
        return 0
    fi

    if ! ufw allow "$SSH_PORT/tcp"; then
        echo "无法通过 UFW 放行 TCP $SSH_PORT。" >&2
        return 1
    fi
    UFW_RULE_ADDED=1
    echo "已通过 UFW 放行 TCP $SSH_PORT。"
    return 0
}

rollback_ufw_port() {
    if [[ $UFW_RULE_ADDED -eq 1 ]]; then
        if ufw --force delete allow "$SSH_PORT/tcp" >/dev/null 2>&1; then
            echo "已删除本次新增的 UFW TCP $SSH_PORT 规则。" >&2
        else
            echo "警告: 未能自动删除本次新增的 UFW TCP $SSH_PORT 规则，请手动检查。" >&2
        fi
    fi
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

write_hardened_config() {
    awk -v port="$SSH_PORT" '
        function emit_missing() {
            if (!seen["pubkeyauthentication"]) print "PubkeyAuthentication yes"
            if (!seen["passwordauthentication"]) print "PasswordAuthentication no"
            if (!seen["kbdinteractiveauthentication"]) print "KbdInteractiveAuthentication no"
            if (!seen["permitrootlogin"]) print "PermitRootLogin no"
            if (!seen["port"]) print "Port " port
        }

        BEGIN { in_global = 1 }

        {
            lower = tolower($0)
            if (in_global && lower ~ /^[[:space:]]*match([[:space:]]|$)/) {
                emit_missing()
                in_global = 0
            }

            if (in_global && lower ~ /^[[:space:]]*pubkeyauthentication[[:space:]]+/) {
                if (!seen["pubkeyauthentication"]++) print "PubkeyAuthentication yes"
                next
            }
            if (in_global && lower ~ /^[[:space:]]*passwordauthentication[[:space:]]+/) {
                if (!seen["passwordauthentication"]++) print "PasswordAuthentication no"
                next
            }
            if (in_global && lower ~ /^[[:space:]]*kbdinteractiveauthentication[[:space:]]+/) {
                if (!seen["kbdinteractiveauthentication"]++) print "KbdInteractiveAuthentication no"
                next
            }
            if (in_global && lower ~ /^[[:space:]]*permitrootlogin[[:space:]]+/) {
                if (!seen["permitrootlogin"]++) print "PermitRootLogin no"
                next
            }
            if (in_global && lower ~ /^[[:space:]]*port[[:space:]]+/) {
                if (!seen["port"]++) print "Port " port
                next
            }

            print
        }

        END {
            if (in_global) emit_missing()
        }
    ' "$SSHD_CONFIG" >"$TMP_FILE"
}

if [[ $EUID -ne 0 ]]; then
    die "请使用 sudo 运行，例如: sudo $0${TARGET_USER:+ --user "$TARGET_USER"}"
fi

[[ "$(get_os)" == "linux" ]] || die "当前仅支持 systemd 管理 SSH 服务的 Linux 服务器"
command -v systemctl >/dev/null 2>&1 || die "未找到 systemctl，无法安全重载 SSH 服务"
if [[ $SKIP_KEY_CHECK -eq 0 ]]; then
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
fi

SSHD_BIN=$(find_sshd)
[[ -n "$SSHD_BIN" ]] || die "未找到 sshd"
SSHD_CONFIG=/etc/ssh/sshd_config
[[ -r "$SSHD_CONFIG" ]] || die "无法读取 $SSHD_CONFIG"

DROP_IN_DIR=/etc/ssh/sshd_config.d
DROP_IN="$DROP_IN_DIR/99-dotfile-key-only.conf"

if ! sshd_already_uses_port && port_is_in_use; then
    die "TCP $SSH_PORT 已被其他服务监听；请选择空闲端口后再修改脚本"
fi

echo "将为 SSH 启用公钥认证，关闭密码、交互式认证和 root 登录，并改用端口 $SSH_PORT。"
if [[ $SKIP_KEY_CHECK -eq 1 ]]; then
    echo "已选择跳过本地 authorized_keys 检查。"
    echo "请确认仍可通过其他已验证方式登录。"
else
    echo "已确认 $TARGET_USER 的公钥文件: $AUTHORIZED_KEYS"
fi
echo "配置文件: $SSHD_CONFIG"
echo "若 UFW 已启用，脚本会自动放行 TCP $SSH_PORT；请确认云安全组已放行。"
if [[ $ASSUME_YES -ne 1 ]]; then
    if [[ $SKIP_KEY_CHECK -eq 1 ]]; then
        read -r -p "确认仍有其他登录方式且云安全组已放行 TCP $SSH_PORT？[y/N] " answer
    else
        read -r -p "确认云安全组已放行 TCP $SSH_PORT 并继续？[y/N] " answer
    fi
    [[ "$answer" =~ ^[Yy]$ ]] || { echo "已取消，未修改配置。"; exit 0; }
fi

STAMP=$(date +%Y%m%d%H%M%S)
CONFIG_BACKUP="${SSHD_CONFIG}.bak.${STAMP}"
DROP_IN_BACKUP=""
cp -p "$SSHD_CONFIG" "$CONFIG_BACKUP"

if [[ -f "$DROP_IN" ]]; then
    DROP_IN_BACKUP="/etc/ssh/sshd_config.bak.${STAMP}.dotfile-key-only.conf"
    cp -p "$DROP_IN" "$DROP_IN_BACKUP"
    rm -f "$DROP_IN"
fi

TMP_FILE=$(mktemp "${SSHD_CONFIG}.tmp.XXXXXX")
VALIDATION_ERROR=$(mktemp)
trap 'rm -f "$TMP_FILE" "$VALIDATION_ERROR"' EXIT

write_hardened_config
install -m "$(stat -c '%a' "$SSHD_CONFIG")" -o "$(stat -c '%u' "$SSHD_CONFIG")" -g "$(stat -c '%g' "$SSHD_CONFIG")" "$TMP_FILE" "$SSHD_CONFIG"

restore_config() {
    cp -p "$CONFIG_BACKUP" "$SSHD_CONFIG"
    if [[ -n "$DROP_IN_BACKUP" ]]; then
        mkdir -p "$DROP_IN_DIR"
        cp -p "$DROP_IN_BACKUP" "$DROP_IN"
    else
        rm -f "$DROP_IN"
    fi
}

if ! ensure_ufw_port; then
    restore_config
    die "UFW 规则添加失败，已恢复原 SSH 配置"
fi

if ! "$SSHD_BIN" -t -f "$SSHD_CONFIG" 2>"$VALIDATION_ERROR"; then
    restore_config
    rollback_ufw_port
    echo "sshd 配置校验输出：" >&2
    cat "$VALIDATION_ERROR" >&2
    die "新配置未通过校验，已恢复原文件"
fi

if ! config_is_hardened; then
    restore_config
    rollback_ufw_port
    die "新配置未成为 sshd 的生效设置（可能被更早的配置覆盖），已恢复原文件"
fi

if ! reload_sshd; then
    restore_config
    rollback_ufw_port
    die "无法重载 ssh/sshd 服务，已恢复原文件；请检查 systemctl 状态"
fi

if ! config_is_hardened; then
    restore_config
    reload_sshd || true
    rollback_ufw_port
    die "重载后设置未生效，已恢复原文件并尝试重载旧配置"
fi

echo "已启用仅公钥 SSH 登录，已禁止 root 登录，SSH 端口已改为 $SSH_PORT。"
echo "原 SSH 配置已备份到: $CONFIG_BACKUP"
[[ -n "$DROP_IN_BACKUP" ]] && echo "旧的 dotfile SSH drop-in 已备份到: $DROP_IN_BACKUP"
echo "请保持当前会话，另开终端确认可通过密钥连接到端口 $SSH_PORT 后再退出。"
