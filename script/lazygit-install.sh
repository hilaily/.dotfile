#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if command -v lazygit &>/dev/null; then
	echo -e "${GREEN}lazygit 已安装:${NC}"
	lazygit --version
	exit 0
fi

install_via_brew() {
	if ! command -v brew &>/dev/null; then
		return 1
	fi
	echo -e "${YELLOW}使用 Homebrew 安装 lazygit...${NC}"
	brew install lazygit
}

install_via_apt() {
	if ! command -v apt-get &>/dev/null; then
		return 1
	fi
	echo -e "${YELLOW}使用 apt 安装 lazygit...${NC}"
	sudo apt-get update
	sudo apt-get install -y lazygit
}

# 从 GitHub Release 解压到 ~/.local/bin（与 nvim/init.lua 中的 PATH 一致）
install_via_release() {
	local ver
	ver=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" |
		grep '"tag_name":' |
		sed -E 's/.*"v([^"]+)".*/\1/')
	if [[ -z "$ver" ]]; then
		echo -e "${RED}无法解析 lazygit 最新版本号${NC}" >&2
		return 1
	fi

	local os_raw arch_raw asset url
	os_raw=$(uname -s)
	arch_raw=$(uname -m)

	case "${os_raw}-${arch_raw}" in
	Darwin-arm64) asset="lazygit_${ver}_Darwin_arm64.tar.gz" ;;
	Darwin-x86_64) asset="lazygit_${ver}_Darwin_x86_64.tar.gz" ;;
	Linux-x86_64) asset="lazygit_${ver}_Linux_x86_64.tar.gz" ;;
	Linux-aarch64 | Linux-arm64) asset="lazygit_${ver}_Linux_arm64.tar.gz" ;;
	*)
		echo -e "${RED}当前平台不支持自动下载二进制: ${os_raw} ${arch_raw}${NC}" >&2
		return 1
		;;
	esac

	url="https://github.com/jesseduffield/lazygit/releases/download/v${ver}/${asset}"
	local tmpdir dest_bin
	tmpdir=$(mktemp -d)
	dest_bin="${HOME}/.local/bin"

	echo -e "${YELLOW}下载 lazygit v${ver} (${asset})...${NC}"
	curl -fsSL -o "${tmpdir}/${asset}" "${url}"
	tar -xzf "${tmpdir}/${asset}" -C "${tmpdir}"

	mkdir -p "${dest_bin}"
	mv -f "${tmpdir}/lazygit" "${dest_bin}/lazygit"
	chmod +x "${dest_bin}/lazygit"
	rm -rf "${tmpdir}"

	echo -e "${GREEN}已安装到 ${dest_bin}/lazygit${NC}"
	if [[ ":${PATH}:" != *":${dest_bin}:"* ]]; then
		echo -e "${YELLOW}提示: 请将 ${dest_bin} 加入 PATH（例如在 ~/.zshrc 中 export PATH=\"\$HOME/.local/bin:\$PATH\"）${NC}"
	fi
}

main() {
	if install_via_brew; then
		:
	elif install_via_apt; then
		:
	elif install_via_release; then
		:
	else
		echo -e "${RED}lazygit 安装失败：未找到 brew/apt，且当前平台无法使用官方二进制发布包。${NC}" >&2
		exit 1
	fi

	echo -e "${GREEN}lazygit 安装完成:${NC}"
	command -v lazygit
	lazygit --version
}

main
