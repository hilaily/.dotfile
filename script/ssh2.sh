#!/bin/bash
# 复制 SSH 公钥，并把连接保存为 ~/.ssh/config.d/ 下的别名

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: ssh2 [ssh-copy-id 选项] [user@]hostname

先运行 ssh-copy-id；复制成功后询问 SSH 别名，并写入：
  ~/.ssh/config.d/<别名>.conf

常用选项:
  -i FILE       指定要复制的公钥
  -p PORT       指定 SSH 端口
  -o OPTION     传递 SSH 选项
  -F CONFIG     指定 SSH 配置文件
  -f, -n, -s    原样传递给 ssh-copy-id
  -h, --help    显示此帮助

示例:
  ssh2 root@192.168.1.10
  ssh2 -i ~/.ssh/id_ed25519.pub -p 2222 root@example.com
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

if [ "$#" -eq 0 ]; then
    usage
    exit 1
fi

if ! command -v ssh-copy-id >/dev/null 2>&1; then
    echo "错误: 未找到 ssh-copy-id" >&2
    exit 1
fi

if ! command -v ssh >/dev/null 2>&1; then
    echo "错误: 未找到 ssh" >&2
    exit 1
fi

args=("$@")
last_index=$((${#args[@]} - 1))
target="${args[$last_index]}"

if [ -z "$target" ] || [[ "$target" == -* ]]; then
    echo "错误: 缺少 [user@]hostname" >&2
    usage >&2
    exit 1
fi

dry_run=0
identity_file=""
resolve_args=()

for ((i = 0; i < last_index; i++)); do
    arg="${args[$i]}"
    case "$arg" in
        -n)
            dry_run=1
            ;;
        -i)
            if ((i + 1 < last_index)); then
                i=$((i + 1))
                identity_file="${args[$i]}"
                identity_file="${identity_file%.pub}"
                resolve_args+=("-i" "$identity_file")
            fi
            ;;
        -i?*)
            identity_file="${arg#-i}"
            identity_file="${identity_file%.pub}"
            resolve_args+=("-i" "$identity_file")
            ;;
        -p | -o | -F)
            if ((i + 1 >= last_index)); then
                echo "错误: $arg 缺少参数" >&2
                exit 1
            fi
            resolve_args+=("$arg" "${args[$((i + 1))]}")
            i=$((i + 1))
            ;;
        -p?* | -o?* | -F?*)
            resolve_args+=("$arg")
            ;;
        -t)
            if ((i + 1 >= last_index)); then
                echo "错误: -t 缺少参数" >&2
                exit 1
            fi
            i=$((i + 1))
            ;;
    esac
done

echo "运行: ssh-copy-id $*"
ssh-copy-id "$@"

if [ "$dry_run" -eq 1 ]; then
    echo "ssh-copy-id 为 dry-run，跳过写入 SSH 配置。"
    exit 0
fi

resolved_config="$(ssh -G "${resolve_args[@]}" "$target" 2>/dev/null || true)"

config_value() {
    local key="$1"
    awk -v wanted="$key" '
        tolower($1) == tolower(wanted) {
            $1 = ""
            sub(/^[[:space:]]+/, "")
            print
            exit
        }
    ' <<<"$resolved_config"
}

hostname="$(config_value hostname)"
username="$(config_value user)"
port="$(config_value port)"
proxy_jump="$(config_value proxyjump)"
proxy_command="$(config_value proxycommand)"

plain_target="${target#ssh://}"
fallback_host="${plain_target##*@}"
fallback_user=""
if [[ "$plain_target" == *@* ]]; then
    fallback_user="${plain_target%@*}"
fi

hostname="${hostname:-$fallback_host}"
username="${username:-$fallback_user}"
port="${port:-22}"

SSH_DIR="$HOME/.ssh"
SSH_CONFIG="$SSH_DIR/config"
SSH_CONFIG_DIR="$SSH_DIR/config.d"
INCLUDE_LINE="Include ~/.ssh/config.d/*"

find_alias_file() {
    local alias_name="$1"
    local file

    for file in "$SSH_CONFIG" "$SSH_CONFIG_DIR"/*; do
        [ -f "$file" ] || continue
        if awk -v alias_name="$alias_name" '
            tolower($1) == "host" {
                for (i = 2; i <= NF; i++) {
                    if (tolower($i) == tolower(alias_name)) {
                        found = 1
                    }
                }
            }
            END { exit(found ? 0 : 1) }
        ' "$file"; then
            printf '%s\n' "$file"
            return 0
        fi
    done
    return 1
}

ensure_config_include() {
    mkdir -p "$SSH_CONFIG_DIR"
    chmod 700 "$SSH_DIR" "$SSH_CONFIG_DIR"

    if [ ! -f "$SSH_CONFIG" ]; then
        printf '%s\n' "$INCLUDE_LINE" >"$SSH_CONFIG"
        chmod 600 "$SSH_CONFIG"
        echo "已创建 $SSH_CONFIG"
        return
    fi

    if awk '
        tolower($1) == "include" {
            for (i = 2; i <= NF; i++) {
                if (tolower($i) ~ /(^|\/)config\.d\/\*/) {
                    found = 1
                }
            }
        }
        END { exit(found ? 0 : 1) }
    ' "$SSH_CONFIG"; then
        chmod 600 "$SSH_CONFIG"
        return
    fi

    local timestamp backup tmp
    timestamp="$(date +%Y%m%d%H%M%S)"
    backup="$SSH_CONFIG.backup.$timestamp"
    tmp="$(mktemp "${TMPDIR:-/tmp}/ssh2-config.XXXXXX")"
    cp -p "$SSH_CONFIG" "$backup"

    awk -v include_line="$INCLUDE_LINE" '
        BEGIN {
            print "# Managed SSH config fragments"
            print include_line
            print ""
        }
        { print }
    ' "$SSH_CONFIG" >"$tmp"

    cp "$tmp" "$SSH_CONFIG"
    rm -f "$tmp"
    chmod 600 "$SSH_CONFIG"
    echo "已在 $SSH_CONFIG 中加入 config.d，并备份到 $backup"
}

alias_name=""
config_file=""
while :; do
    if ! read -r -p "SSH 别名（如 prod-web，留空取消）: " alias_name; then
        echo "未写入 SSH 配置。" >&2
        exit 1
    fi

    if [ -z "$alias_name" ]; then
        echo "已复制公钥，未写入 SSH 配置。"
        exit 0
    fi

    if [[ ! "$alias_name" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
        echo "别名只能包含字母、数字、点、下划线和连字符。" >&2
        continue
    fi

    config_file="$SSH_CONFIG_DIR/$alias_name.conf"
    existing_file="$(find_alias_file "$alias_name" || true)"
    if [ -n "$existing_file" ] && [ "$existing_file" != "$config_file" ]; then
        echo "别名 '$alias_name' 已存在于 $existing_file，请换一个名字。" >&2
        continue
    fi

    if [ -f "$config_file" ]; then
        if ! read -r -p "$config_file 已存在，是否覆盖？[y/N] " answer; then
            echo "未写入 SSH 配置。" >&2
            exit 1
        fi
        case "$answer" in
            y | Y | yes | YES)
                cp -p "$config_file" "$config_file.backup.$(date +%Y%m%d%H%M%S)"
                ;;
            *)
                continue
                ;;
        esac
    fi
    break
done

ensure_config_include

tmp_config="$(mktemp "${TMPDIR:-/tmp}/ssh2-host.XXXXXX")"
{
    printf 'Host %s\n' "$alias_name"
    printf '    HostName %s\n' "$hostname"
    [ -n "$username" ] && printf '    User %s\n' "$username"
    printf '    Port %s\n' "$port"
    if [ -n "$identity_file" ]; then
        if [[ "$identity_file" == "$HOME/"* ]]; then
            identity_file="~/${identity_file#"$HOME/"}"
        fi
        printf '    IdentityFile %s\n' "$identity_file"
        printf '    IdentitiesOnly yes\n'
    fi
    [ -n "$proxy_jump" ] && [ "$proxy_jump" != "none" ] && printf '    ProxyJump %s\n' "$proxy_jump"
    [ -n "$proxy_command" ] && [ "$proxy_command" != "none" ] && printf '    ProxyCommand %s\n' "$proxy_command"
} >"$tmp_config"

chmod 600 "$tmp_config"
mv "$tmp_config" "$config_file"

echo "已写入 $config_file"
echo "以后可直接运行: ssh $alias_name"
