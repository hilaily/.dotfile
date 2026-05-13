#!/bin/bash

set -euo pipefail

usage() {
    cat <<'EOF'
用法: dirsize [选项] [目录]

查询目录大小，默认扫描当前目录的直接子目录。

选项:
  -a, --all        递归显示所有子目录的大小
  -d, --depth N    指定递归深度 (默认 1)
  -n, --top N      只显示前 N 名 (默认全部)
  -r, --reverse    按从小到大排序 (默认从大到小)
  -h, --help       显示帮助信息

示例:
  dirsize                  当前目录的直接子目录大小
  dirsize -n 10            当前目录的直接子目录，取前 10 名
  dirsize -a               递归显示所有子目录
  dirsize -d 2 -n 5        深度 2，取前 5 名
  dirsize -n 5 /var/log    查看 /var/log 的子目录，取前 5 名
EOF
    exit 0
}

DEPTH=1
TOP=0
REVERSE=false
ALL=false
TARGET_DIR="."

while [[ $# -gt 0 ]]; do
    case "$1" in
        -a|--all)    ALL=true; shift ;;
        -d|--depth)  DEPTH="$2"; shift 2 ;;
        -n|--top)    TOP="$2"; shift 2 ;;
        -r|--reverse) REVERSE=true; shift ;;
        -h|--help)   usage ;;
        -*)          echo "未知选项: $1" >&2; usage ;;
        *)           TARGET_DIR="$1"; shift ;;
    esac
done

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "错误: '$TARGET_DIR' 不是有效目录" >&2
    exit 1
fi

TARGET_DIR="${TARGET_DIR%/}"

if $ALL; then
    DEPTH=999
fi

sort_flag="-rh"
if $REVERSE; then
    sort_flag="-h"
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    result=$(du -h -d "$DEPTH" "$TARGET_DIR" 2>/dev/null | grep -v "^.*${TARGET_DIR}$" | sort $sort_flag)
else
    result=$(du -h --max-depth="$DEPTH" "$TARGET_DIR" 2>/dev/null | grep -v "^.*${TARGET_DIR}$" | sort $sort_flag)
fi

if [[ "$TOP" -gt 0 ]]; then
    result=$(echo "$result" | head -n "$TOP")
fi

if [[ -z "$result" ]]; then
    echo "目录为空或无子目录"
    exit 0
fi

echo "$result"
