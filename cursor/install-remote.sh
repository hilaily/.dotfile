#!/bin/bash

set -e
set -x

# 设置环境变量
export CURSOR_VERSION=
export CURSOR_COMMIT=
export REMOTE_ARCH="x64" # or arm64
export REMOTE_OS="linux"

# 创建目录结构
mkdir -p ${HOME}/.cursor-server/cli/servers/Stable-${CURSOR_COMMIT}/server/

# 下载并解压第一个压缩包 (cli-alpine)
CLI_URL="https://cursor.blob.core.windows.net/remote-releases/${CURSOR_COMMIT}/cli-alpine-${REMOTE_ARCH}.tar.gz"
curl -L "${CLI_URL}" -o ${HOME}/.cursor-server/cursor-cli.tar.gz
tar -xzf ${HOME}/.cursor-server/cursor-cli.tar.gz -C ${HOME}/.cursor-server/
mv ${HOME}/.cursor-server/cursor ${HOME}/.cursor-server/cursor-$CURSOR_COMMIT

# 下载并解压第二个压缩包 (vscode-reh)
VSCODE_URL="https://cursor.blob.core.windows.net/remote-releases/${CURSOR_VERSION}-${CURSOR_COMMIT}/vscode-reh-${REMOTE_OS}-${REMOTE_ARCH}.tar.gz"
curl -L "${VSCODE_URL}" -o ${HOME}/.cursor-server/cursor-vscode-server.tar.gz
tar -xzf ${HOME}/.cursor-server/cursor-vscode-server.tar.gz -C ${HOME}/.cursor-server/cli/servers/Stable-${CURSOR_COMMIT}/server/ --strip-components=1

echo "Cursor server installation completed!"