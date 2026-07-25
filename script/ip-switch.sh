#!/bin/bash
# 交互式设置网卡静态 IPv4 地址或切回 DHCP

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: ip-switch

交互选择网络服务/网卡，并设置临时静态 IPv4 地址或切换回 DHCP。

支持:
  macOS  使用 networksetup 管理网络服务
  Linux  优先使用 NetworkManager (nmcli)；否则使用 ip + DHCP 客户端

选项:
  -h, --help  显示此帮助

说明:
  修改网络配置通常需要 sudo。Linux 下通过 nmcli 或 ip 做出的修改仅作用于
  当前连接，不会写入连接配置文件；重新连接后会恢复原配置。
  ip 命令本身不能获取 DHCP 租约；切回 DHCP 时需要 dhclient、udhcpc 或 dhcpcd。
  设置静态地址时，子网掩码默认 255.255.255.0，默认网关按 IP 推导为 x.x.x.1。
  远程 SSH 连接中运行时，修改当前网卡可能会导致连接中断。
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

set -euo pipefail

OS="$(uname -s)"

die() {
    echo "错误: $*" >&2
    exit 1
}

is_ipv4() {
    local ip="$1" octet
    [[ "$ip" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]] || return 1
    IFS='.' read -r -a octets <<<"$ip"
    for octet in "${octets[@]}"; do
        ((10#$octet <= 255)) || return 1
    done
}

netmask_to_prefix() {
    case "$1" in
        255.255.255.255) echo 32 ;;
        255.255.255.254) echo 31 ;;
        255.255.255.252) echo 30 ;;
        255.255.255.248) echo 29 ;;
        255.255.255.240) echo 28 ;;
        255.255.255.224) echo 27 ;;
        255.255.255.192) echo 26 ;;
        255.255.255.128) echo 25 ;;
        255.255.255.0) echo 24 ;;
        255.255.254.0) echo 23 ;;
        255.255.252.0) echo 22 ;;
        255.255.248.0) echo 21 ;;
        255.255.240.0) echo 20 ;;
        255.255.224.0) echo 19 ;;
        255.255.192.0) echo 18 ;;
        255.255.128.0) echo 17 ;;
        255.255.0.0) echo 16 ;;
        255.254.0.0) echo 15 ;;
        255.252.0.0) echo 14 ;;
        255.248.0.0) echo 13 ;;
        255.240.0.0) echo 12 ;;
        255.224.0.0) echo 11 ;;
        255.192.0.0) echo 10 ;;
        255.128.0.0) echo 9 ;;
        255.0.0.0) echo 8 ;;
        254.0.0.0) echo 7 ;;
        252.0.0.0) echo 6 ;;
        248.0.0.0) echo 5 ;;
        240.0.0.0) echo 4 ;;
        224.0.0.0) echo 3 ;;
        192.0.0.0) echo 2 ;;
        128.0.0.0) echo 1 ;;
        0.0.0.0) echo 0 ;;
        *) return 1 ;;
    esac
}

confirm() {
    local answer
    read -r -p "确认应用此网络配置？[y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

select_item() {
    local prompt="$1" item index=1 choice
    shift
    local -a items=("$@")

    echo
    for item in "${items[@]}"; do
        printf '  %d) %s\n' "$index" "$item"
        ((index += 1))
    done
    echo "  0) 取消"

    while true; do
        read -r -p "$prompt" choice
        [[ "$choice" == "0" || "$choice" == "q" || "$choice" == "Q" ]] && return 1
        if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#items[@]})); then
            SELECTED_INDEX=$((choice - 1))
            return 0
        fi
        echo "请输入列表中的编号。"
    done
}

prompt_static_config() {
    local default_gateway

    while true; do
        read -r -p "IPv4 地址: " STATIC_IP
        is_ipv4 "$STATIC_IP" && break
        echo "请输入有效的 IPv4 地址。"
    done

    while true; do
        read -r -p "子网掩码 [255.255.255.0]: " STATIC_MASK
        STATIC_MASK="${STATIC_MASK:-255.255.255.0}"
        if STATIC_PREFIX=$(netmask_to_prefix "$STATIC_MASK"); then
            break
        fi
        echo "请输入连续的 IPv4 子网掩码，例如 255.255.255.0。"
    done

    default_gateway="${STATIC_IP%.*}.1"
    while true; do
        read -r -p "默认网关 [$default_gateway]: " STATIC_GATEWAY
        STATIC_GATEWAY="${STATIC_GATEWAY:-$default_gateway}"
        is_ipv4 "$STATIC_GATEWAY" && break
        echo "请输入有效的 IPv4 默认网关。"
    done
}

run_macos() {
    local service device current action
    local -a services=() devices=() labels=()

    command -v networksetup >/dev/null || die "找不到 networksetup"

    while IFS=$'\t' read -r service device; do
        [ -n "$service" ] || continue
        services+=("$service")
        devices+=("$device")
        labels+=("$service  ($device)")
    done < <(networksetup -listnetworkserviceorder | awk '
        /^\([0-9]+\) / { service = $0; sub(/^\([0-9]+\) \*?/, "", service); next }
        /Hardware Port:.*Device:/ {
            device = $0; sub(/^.*Device: /, "", device); sub(/\).*/, "", device)
            if (service != "") print service "\t" device
        }
    ')

    ((${#services[@]} > 0)) || die "未发现可配置的网络服务"
    select_item "选择网络服务: " "${labels[@]}" || exit 0
    service="${services[$SELECTED_INDEX]}"
    device="${devices[$SELECTED_INDEX]}"
    current="$(networksetup -getinfo "$service" 2>&1)"

    echo
    echo "当前配置 ($service / $device):"
    echo "$current"
    select_item "选择操作: " "设置静态 IPv4" "切换为 DHCP" || exit 0
    action="$SELECTED_INDEX"

    if ((action == 0)); then
        prompt_static_config
        echo
        printf '将 %s (%s) 设为静态地址: %s / %s，网关: %s\n' \
            "$service" "$device" "$STATIC_IP" "$STATIC_MASK" "$STATIC_GATEWAY"
        confirm || { echo "已取消。"; exit 0; }
        sudo networksetup -setmanual "$service" "$STATIC_IP" "$STATIC_MASK" "$STATIC_GATEWAY"
    else
        echo
        echo "将 $service ($device) 切换为 DHCP。"
        confirm || { echo "已取消。"; exit 0; }
        sudo networksetup -setdhcp "$service"
    fi

    echo
    echo "已应用。当前配置:"
    networksetup -getinfo "$service"
}

run_linux() {
    local device type state action
    local -a devices=() labels=()

    while IFS=: read -r device type state; do
        [ -n "$device" ] || continue
        [ "$type" = "loopback" ] && continue
        devices+=("$device")
        labels+=("$device  ($type, $state)")
    done < <(nmcli -t -f DEVICE,TYPE,STATE device status)

    ((${#devices[@]} > 0)) || die "未发现可配置的网络接口"
    select_item "选择网络接口: " "${labels[@]}" || exit 0
    device="${devices[$SELECTED_INDEX]}"

    echo
    echo "当前配置 ($device):"
    nmcli device show "$device" | awk '/GENERAL.CONNECTION|IP4\.ADDRESS|IP4\.GATEWAY|IP4\.DNS/ { print }'
    select_item "选择操作: " "设置静态 IPv4" "切换为 DHCP" || exit 0
    action="$SELECTED_INDEX"

    if ((action == 0)); then
        prompt_static_config
        echo
        printf '将 %s 设为静态地址: %s/%s，网关: %s\n' \
            "$device" "$STATIC_IP" "$STATIC_PREFIX" "$STATIC_GATEWAY"
        confirm || { echo "已取消。"; exit 0; }
        sudo nmcli device modify "$device" ipv4.method manual \
            ipv4.addresses "$STATIC_IP/$STATIC_PREFIX" ipv4.gateway "$STATIC_GATEWAY"
    else
        echo
        echo "将 $device 切换为 DHCP。"
        confirm || { echo "已取消。"; exit 0; }
        sudo nmcli device modify "$device" ipv4.method auto ipv4.addresses "" ipv4.gateway ""
    fi

    echo
    echo "已应用。当前配置:"
    nmcli device show "$device" | awk '/GENERAL.CONNECTION|IP4\.ADDRESS|IP4\.GATEWAY|IP4\.DNS/ { print }'
}

linux_dhcp_client() {
    if command -v dhclient >/dev/null; then
        echo dhclient
    elif command -v udhcpc >/dev/null; then
        echo udhcpc
    elif command -v dhcpcd >/dev/null; then
        echo dhcpcd
    fi
}

run_linux_ip() {
    local device action dhcp_client
    local -a devices=() labels=()

    command -v ip >/dev/null || die "找不到 ip 命令"

    while IFS= read -r device; do
        [ -n "$device" ] || continue
        devices+=("$device")
        labels+=("$device  ($(ip -br link show dev "$device" | awk '{ print $2 }'))")
    done < <(ip -o link show | awk -F': ' '$2 != "lo" { sub(/@.*/, "", $2); print $2 }')

    ((${#devices[@]} > 0)) || die "未发现可配置的网络接口"
    select_item "选择网络接口: " "${labels[@]}" || exit 0
    device="${devices[$SELECTED_INDEX]}"

    echo
    echo "当前配置 ($device):"
    ip -br -4 addr show dev "$device"
    ip route show default dev "$device" || true
    select_item "选择操作: " "设置静态 IPv4" "切换为 DHCP" || exit 0
    action="$SELECTED_INDEX"

    if ((action == 0)); then
        prompt_static_config
        echo
        printf '将 %s 设为静态地址: %s/%s，网关: %s\n' \
            "$device" "$STATIC_IP" "$STATIC_PREFIX" "$STATIC_GATEWAY"
        confirm || { echo "已取消。"; exit 0; }
        sudo ip link set dev "$device" up
        sudo ip -4 addr flush dev "$device"
        sudo ip -4 addr add "$STATIC_IP/$STATIC_PREFIX" dev "$device"
        sudo ip route replace default via "$STATIC_GATEWAY" dev "$device"
    else
        dhcp_client="$(linux_dhcp_client)"
        [ -n "$dhcp_client" ] || die "切回 DHCP 需要 dhclient、udhcpc 或 dhcpcd；请安装与现有网络管理方式兼容的 DHCP 客户端"
        echo
        echo "将 $device 切换为 DHCP（使用 $dhcp_client）。"
        confirm || { echo "已取消。"; exit 0; }
        sudo ip link set dev "$device" up

        case "$dhcp_client" in
            dhclient)
                sudo dhclient -4 -r "$device" 2>/dev/null || true
                sudo ip -4 addr flush dev "$device"
                sudo ip route flush default dev "$device" 2>/dev/null || true
                sudo dhclient -4 -v "$device"
                ;;
            udhcpc)
                sudo ip -4 addr flush dev "$device"
                sudo ip route flush default dev "$device" 2>/dev/null || true
                sudo udhcpc -i "$device" -q -n
                ;;
            dhcpcd)
                sudo ip -4 addr flush dev "$device"
                sudo ip route flush default dev "$device" 2>/dev/null || true
                sudo dhcpcd -4 "$device"
                ;;
        esac
    fi

    echo
    echo "已应用。当前配置:"
    ip -br -4 addr show dev "$device"
    ip route show default dev "$device" || true
}

case "$OS" in
    Darwin) run_macos ;;
    Linux)
        if command -v nmcli >/dev/null && systemctl is-active --quiet NetworkManager 2>/dev/null; then
            run_linux
        else
            run_linux_ip
        fi
        ;;
    *) die "不支持的操作系统: $OS" ;;
esac
