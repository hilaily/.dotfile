#!/bin/bash

set -eu

usage() {
    cat <<'EOF'
用法: dirsize [选项] [目录]

查询目录大小，默认列出当前目录下的直接子目录和子文件。

选项:
  -a, --all        递归显示所有子目录的大小
  -d, --depth N    指定递归深度 (默认 1)
  -n, --top N      只显示前 N 名 (默认全部)
  -r, --reverse    按从小到大排序 (默认从大到小)
  -h, --help       显示帮助信息

示例:
  dirsize                  当前目录的直接子项大小
  dirsize -n 10            当前目录的直接子项，取前 10 名
  dirsize -a               递归显示所有子目录
  dirsize -d 2 -n 5        深度 2，取前 5 名
  dirsize -n 5 /var/log    查看 /var/log 的子项，取前 5 名
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
    -a | --all)
        ALL=true
        shift
        ;;
    -d | --depth)
        DEPTH="$2"
        shift 2
        ;;
    -n | --top)
        TOP="$2"
        shift 2
        ;;
    -r | --reverse)
        REVERSE=true
        shift
        ;;
    -h | --help) usage ;;
    -*)
        echo "未知选项: $1" >&2
        usage
        ;;
    *)
        TARGET_DIR="$1"
        shift
        ;;
    esac
done

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "错误: '$TARGET_DIR' 不是有效目录" >&2
    exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd -P)"

if $ALL; then
    DEPTH=999
fi

sort_flag="-rh"
if $REVERSE; then
    sort_flag="-h"
fi

list_dir_sizes() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sudo du -h -d "$DEPTH" "$TARGET_DIR" 2>/dev/null
    else
        sudo du -h --max-depth="$DEPTH" "$TARGET_DIR" 2>/dev/null
    fi | awk -v dir="$TARGET_DIR" '$2 != dir {print}'
}

# 用 ls 读取直接子文件（一次 readdir），避免 find 递归
list_direct_file_sizes() {
    sudo ls -lA "$TARGET_DIR" 2>/dev/null | awk -v dir="$TARGET_DIR" '
        function human(bytes,    units, i, size) {
            split("B K M G T", units, " ")
            i = 1
            size = bytes
            while (size >= 1024 && i < 5) {
                size /= 1024
                i++
            }
            if (i == 1) {
                return sprintf("%dB", bytes)
            }
            return sprintf("%.1f%s", size, units[i])
        }
        /^-/ {
            name = $9
            for (i = 10; i <= NF; i++) {
                name = name " " $i
            }
            printf "%s\t%s/%s\n", human($5), dir, name
        }
    '
}

result=$(
    {
        list_dir_sizes
        list_direct_file_sizes
    } | sort $sort_flag
)

if [[ "$TOP" -gt 0 ]]; then
    result=$(echo "$result" | head -n "$TOP")
fi

if [[ -z "$result" ]]; then
    echo "目录为空"
    exit 0
fi

echo "$result"
