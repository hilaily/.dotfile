#!/bin/bash
# 快速检查服务器 SSH、端口、防火墙、特权账号与近期登录风险

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/os-arch.sh"

usage() {
    cat <<'EOF'
用法: server-security-check

快速、只读地检查以下服务器安全项：
  - SSH 是否允许 root 或密码登录
  - 当前监听端口，以及常见明文服务端口
  - 本机防火墙是否启用
  - UID 0 异常账号和 sudoers 中非 root 主体的免密 sudo 规则
  - 最近 24 小时 SSH 失败登录摘要和最近成功登录来源

选项:
  -h, --help  显示此帮助

说明:
  不扫描网络、不查询漏洞库、不修改配置，通常可在数秒内完成。
  建议使用 sudo 运行，以读取 sudoers 和系统认证日志：
    sudo server-security-check
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

if [[ $# -ne 0 ]]; then
    echo "错误: 不支持参数: $*" >&2
    usage >&2
    exit 1
fi

PASS_COUNT=0
WARN_COUNT=0
HIGH_COUNT=0
INFO_COUNT=0

pass() {
    PASS_COUNT=$((PASS_COUNT + 1))
    printf '[通过] %s\n' "$*"
}

warn() {
    WARN_COUNT=$((WARN_COUNT + 1))
    printf '[警告] %s\n' "$*"
}

high() {
    HIGH_COUNT=$((HIGH_COUNT + 1))
    printf '[高风险] %s\n' "$*"
}

info() {
    INFO_COUNT=$((INFO_COUNT + 1))
    printf '[信息] %s\n' "$*"
}

section() {
    printf '\n== %s ==\n' "$1"
}

find_sshd() {
    local candidate
    if command -v sshd >/dev/null 2>&1; then
        command -v sshd
        return
    fi

    for candidate in /usr/sbin/sshd /usr/local/sbin/sshd; do
        if [[ -x "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return
        fi
    done
}

check_sshd_setting() {
    local setting="$1" value
    value=$(printf '%s\n' "$SSHD_EFFECTIVE_CONFIG" | awk -v key="$setting" '$1 == key { print $2; exit }')
    printf '%s' "$value"
}

check_ssh() {
    local sshd_bin root_login password_login

    section "SSH 登录"
    sshd_bin=$(find_sshd)
    if [[ -z "$sshd_bin" ]]; then
        info "未安装 sshd，跳过 SSH 配置检查"
        return
    fi

    SSHD_EFFECTIVE_CONFIG=$("$sshd_bin" -T 2>/dev/null)
    if [[ -z "$SSHD_EFFECTIVE_CONFIG" ]]; then
        warn "无法读取 sshd 生效配置；请使用 sudo 重试或检查 sshd 配置"
        return
    fi

    root_login=$(check_sshd_setting permitrootlogin)
    password_login=$(check_sshd_setting passwordauthentication)

    case "$root_login" in
        no|forced-commands-only)
            pass "SSH 已禁止 root 交互式登录（PermitRootLogin: $root_login）"
            ;;
        prohibit-password)
            pass "SSH root 登录仅允许密钥认证（PermitRootLogin: prohibit-password）"
            ;;
        yes)
            high "SSH 允许 root 直接登录；建议设为 PermitRootLogin no"
            ;;
        *)
            warn "无法确定 PermitRootLogin 的安全状态（当前: ${root_login:-未设置}）"
            ;;
    esac

    case "$password_login" in
        no)
            pass "SSH 已禁用密码登录"
            ;;
        yes)
            warn "SSH 允许密码登录；公网服务器建议改用密钥认证"
            ;;
        *)
            warn "无法确定 PasswordAuthentication 的安全状态（当前: ${password_login:-未设置}）"
            ;;
    esac
}

check_listening_ports() {
    local listeners risky

    section "监听端口"
    if [[ "$OS_NAME" == "linux" ]] && command -v ss >/dev/null 2>&1; then
        listeners=$(ss -H -lntu 2>/dev/null)
    elif [[ "$OS_NAME" == "darwin" ]] && command -v lsof >/dev/null 2>&1; then
        listeners=$(lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | sed 1d)
    elif command -v netstat >/dev/null 2>&1; then
        listeners=$(netstat -lnt 2>/dev/null || netstat -an 2>/dev/null)
    else
        warn "找不到 ss、lsof 或 netstat，无法列出监听端口"
        return
    fi

    if [[ -z "$listeners" ]]; then
        pass "未发现 TCP/UDP 监听端口"
        return
    fi

    printf '%s\n' "$listeners" | sed -n '1,30p'
    local listener_count
    listener_count=$(printf '%s\n' "$listeners" | wc -l | tr -d ' ')
    if ((listener_count > 30)); then
        info "仅显示前 30 个监听项，共 ${listener_count} 项"
    fi

    risky=$(printf '%s\n' "$listeners" | grep -E '(:21|:23|:69|:111|:512|:513|:514)([[:space:]]|$)' || true)
    if [[ -n "$risky" ]]; then
        warn "发现 FTP/Telnet/rsh 等常见高风险或明文服务端口：$(printf '%s' "$risky" | tr '\n' ';')"
    else
        pass "未发现常见明文服务端口（21、23、69、111、512-514）"
    fi
}

check_firewall() {
    local ufw_output zones

    section "防火墙"
    case "$OS_NAME" in
        linux)
            if command -v ufw >/dev/null 2>&1; then
                ufw_output=$(ufw status verbose 2>&1)
                if printf '%s\n' "$ufw_output" | grep -qi '^Status: active'; then
                    if printf '%s\n' "$ufw_output" | grep -qi 'Default: deny (incoming)'; then
                        pass "UFW 已启用，默认拒绝入站连接"
                    else
                        warn "UFW 已启用，但未确认默认拒绝入站连接"
                    fi
                else
                    warn "UFW 未启用；若未使用云安全组或其他防火墙，请启用入站访问控制"
                fi
                return
            fi

            if command -v firewall-cmd >/dev/null 2>&1 && firewall-cmd --state 2>/dev/null | grep -qx running; then
                zones=$(firewall-cmd --get-active-zones 2>/dev/null | tr '\n' ';')
                pass "firewalld 正在运行（活动区域: ${zones:-未知}）"
                info "请确认活动区域只放行实际需要的服务"
                return
            fi

            if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet nftables 2>/dev/null; then
                pass "nftables 服务正在运行"
                info "请确认 nftables 的入站默认策略为 drop 或 reject"
                return
            fi

            warn "未检测到正在运行的 UFW、firewalld 或 nftables；若依赖云安全组，请确认其已限制入站端口"
            ;;
        darwin)
            if [[ -x /usr/libexec/ApplicationFirewall/socketfilterfw ]]; then
                if /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null | grep -qi enabled; then
                    pass "macOS 应用防火墙已启用"
                else
                    warn "macOS 应用防火墙未启用"
                fi
            else
                warn "无法读取 macOS 防火墙状态"
            fi
            ;;
        *)
            warn "不支持的系统，无法检测防火墙"
            ;;
    esac
}

add_sudoers_file() {
    local file="$1" existing
    [[ -r "$file" ]] || return

    for existing in "${SUDOERS_FILES[@]}"; do
        [[ "$existing" == "$file" ]] && return
    done
    SUDOERS_FILES+=("$file")
}

collect_sudoers_files() {
    local file
    SUDOERS_FILES=()

    # visudo 会按照 sudo 实际的 #include / #includedir 关系解析配置，并逐个报告已检查的文件。
    if command -v visudo >/dev/null 2>&1; then
        while IFS= read -r file; do
            add_sudoers_file "$file"
        done < <(visudo -c 2>&1 | awk '/: parsed OK$/ {sub(/: parsed OK$/, ""); print}')
    fi

    # 若 visudo 不可用或配置本身有语法错误，仍尽力检查标准位置。
    add_sudoers_file /etc/sudoers
    if [[ -d /etc/sudoers.d ]]; then
        for file in /etc/sudoers.d/*; do
            add_sudoers_file "$file"
        done
    fi
}

check_privileged_accounts() {
    local uid_zero sudo_rules

    section "高权限账号"
    uid_zero=$(awk -F: '$3 == 0 && $1 != "root" {print $1}' /etc/passwd 2>/dev/null)
    if [[ -n "$uid_zero" ]]; then
        high "发现非 root 的 UID 0 账号：$(printf '%s' "$uid_zero" | tr '\n' ' ')"
    else
        pass "未发现非 root 的 UID 0 账号"
    fi

    if [[ $EUID -ne 0 ]]; then
        info "未以 root 运行，跳过完整 sudoers 免密规则检查；可用 sudo 重跑"
        return
    fi

    collect_sudoers_files
    if ((${#SUDOERS_FILES[@]} == 0)); then
        warn "未找到可读取的 sudoers 配置文件"
        return
    fi

    sudo_rules=$(awk '
        /^[[:space:]]*[^#].*NOPASSWD/ {
            rule = $0
            sub(/^[[:space:]]*/, "", rule)

            # root 已拥有完整权限；仅 root 作为规则主体时不构成额外提权路径。
            # 含其他用户、组、别名或 ALL 的规则仍保留告警。
            if (rule ~ /^root[[:space:]]+/) next

            print FILENAME ":" $0
        }
    ' "${SUDOERS_FILES[@]}" 2>/dev/null || true)
    if [[ -n "$sudo_rules" ]]; then
        warn "发现非 root 主体的免密 sudo 规则（含文件路径）：$(printf '%s' "$sudo_rules" | tr '\n' ';')"
    else
        pass "未发现非 root 主体的 NOPASSWD 免密 sudo 规则"
    fi
}

check_recent_logins() {
    local auth_log log_text failed_count successful

    section "近期 SSH 登录"
    auth_log=""
    for candidate in /var/log/auth.log /var/log/secure; do
        if [[ -r "$candidate" ]]; then
            auth_log="$candidate"
            break
        fi
    done

    if [[ -n "$auth_log" ]]; then
        log_text=$(tail -n 5000 "$auth_log" 2>/dev/null)
    elif command -v journalctl >/dev/null 2>&1; then
        log_text=$(journalctl --no-pager --since '24 hours ago' -u ssh -u sshd 2>/dev/null)
    else
        log_text=""
    fi

    if [[ -n "$log_text" ]]; then
        failed_count=$(printf '%s\n' "$log_text" | grep -Eic 'Failed password|Invalid user|authentication failure|Failed publickey' || true)
        if ((failed_count == 0)); then
            pass "最近 24 小时未发现 SSH 失败登录记录"
        elif ((failed_count < 20)); then
            warn "最近 24 小时发现 ${failed_count} 条 SSH 失败登录记录"
        else
            high "最近 24 小时发现 ${failed_count} 条 SSH 失败登录记录，可能存在暴力破解"
        fi
    else
        info "无法读取最近 24 小时 SSH 日志；可用 sudo 重跑，或确认日志服务正常"
    fi

    if command -v last >/dev/null 2>&1; then
        successful=$(last -i -n 5 2>/dev/null | sed -n '/^wtmp begins/q;p' | sed '/^$/d')
        if [[ -n "$successful" ]]; then
            printf '最近成功登录（最多 5 条）：\n%s\n' "$successful"
        else
            info "未读取到成功登录记录"
        fi
    fi
}

OS_NAME=$(get_os)

echo "服务器快速安全检查（系统: ${OS_NAME}/$(get_arch)）"
echo "只读检查；建议使用 sudo 获取完整结果。"

check_ssh
check_listening_ports
check_firewall
check_privileged_accounts
check_recent_logins

printf '\n== 汇总 ==\n'
printf '通过: %d  警告: %d  高风险: %d  信息: %d\n' "$PASS_COUNT" "$WARN_COUNT" "$HIGH_COUNT" "$INFO_COUNT"
if ((HIGH_COUNT > 0)); then
    echo "请优先处理“高风险”项。"
elif ((WARN_COUNT > 0)); then
    echo "建议逐项确认“警告”项是否符合服务器的实际部署方式。"
else
    echo "未发现需要立即处理的项。"
fi
