#!/bin/bash
# 已合并到 git-credential.sh；保留此文件仅为兼容旧配置引用
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/git-credential.sh" "$@"
