#!/bin/bash

# 用法:
#   ./dns-clean.sh    # 清理 macOS / Linux 系统 DNS 缓存

set -e

SUDO=""
[ "$(id -u)" -ne 0 ] && SUDO="sudo"

flush_macos() {
    echo "macOS: 清理 DNS 缓存..."
    $SUDO dscacheutil -flushcache
    $SUDO killall -HUP mDNSResponder 2>/dev/null || true
    $SUDO killall mDNSResponderHelper 2>/dev/null || true
    echo "macOS DNS 缓存已清理"
}

flush_linux() {
    local flushed=0

    echo "Linux: 清理 DNS 缓存..."

    if command -v resolvectl &>/dev/null; then
        if $SUDO resolvectl flush-caches 2>/dev/null; then
            echo "  - systemd-resolved (resolvectl) 缓存已清理"
            flushed=1
        fi
    elif command -v systemd-resolve &>/dev/null; then
        if $SUDO systemd-resolve --flush-caches 2>/dev/null; then
            echo "  - systemd-resolved (systemd-resolve) 缓存已清理"
            flushed=1
        fi
    fi

    if command -v systemctl &>/dev/null; then
        if systemctl is-active --quiet nscd 2>/dev/null; then
            $SUDO systemctl restart nscd
            echo "  - nscd 已重启"
            flushed=1
        fi

        if systemctl is-active --quiet dnsmasq 2>/dev/null; then
            $SUDO systemctl restart dnsmasq
            echo "  - dnsmasq 已重启"
            flushed=1
        fi

        if systemctl is-active --quiet unbound 2>/dev/null; then
            if command -v rndc &>/dev/null; then
                $SUDO rndc flush 2>/dev/null && echo "  - unbound 缓存已清理" && flushed=1
            else
                $SUDO systemctl restart unbound
                echo "  - unbound 已重启"
                flushed=1
            fi
        fi
    fi

    if [ "$flushed" -eq 0 ]; then
        echo "未检测到常见 DNS 缓存服务 (systemd-resolved / nscd / dnsmasq / unbound)"
        echo "若仍有问题，可尝试重启 NetworkManager 或检查本地 DNS 配置"
        exit 1
    fi

    echo "Linux DNS 缓存已清理"
}

case "$(uname -s)" in
    Darwin) flush_macos ;;
    Linux)  flush_linux ;;
    *)
        echo "错误: 不支持的操作系统: $(uname -s)"
        exit 1
        ;;
esac
