#!/bin/bash

# 检查是否输入了目录参数，如果没有，默认使用当前目录
TARGET_DIR=${1:-"."}

echo "--- 正在扫描目录: $TARGET_DIR ---"
echo "--- 正在查找最大的 10 个文件/文件夹 ---"
echo "----------------------------------------"

# 执行查找逻辑
# -d 1: 只查看当前目录层级（不展开子目录的所有细碎文件）
# -h: 以人类可读格式显示 (K, M, G)
# sort -rh: 按人类可读的数字反向排序 (需要支持 -h 的 sort，Mac/Linux 通用)
# head -n 10: 取前 10 名

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac (BSD 版本的 du 略有不同)
    du -sh "$TARGET_DIR"/* | sort -rh | head -n 10
else
    # Linux (GNU 版本)
    du -sh "$TARGET_DIR"/* --max-depth=1 2>/dev/null | sort -rh | head -n 10
fi

echo "----------------------------------------"
echo "扫描完成。"
