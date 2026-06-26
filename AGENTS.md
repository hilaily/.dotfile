# dotfile 维护约定

个人 dotfiles 仓库（`~/.dotfile`）。本文件供 AI coding agent 与维护者共用：新增或改造配置/脚本时请遵循以下规则。

## 常用命令

```bash
ff script -h              # 列出 script/ 下所有脚本及说明
ff script <name>          # 运行脚本
make -f Makefile.scripts <name>   # 同上（make 入口）
ff region                 # 切换 CN_REGION（国内/国外镜像）
ff reload                 # 重载 fish 配置
```

## 目录职责

| 路径 | 用途 |
|------|------|
| `script/` | 可执行脚本（安装、初始化、工具）；已加入 fish `PATH` |
| `script/common/` | 脚本共享片段（`help.sh`、`os-arch.sh`） |
| `fish/default.fish` | 共享 fish 配置（进 git） |
| `~/.config/fish/config.fish` | 本机 wrapper，仅 `source` default.fish + 可选 `custom.fish` |
| `fish/functions/`、`fish/completions/` | fish 函数与补全；`fish-init` 会软链到 `~/.config/fish/` |
| `git/`、`nvim/`、`tmux/`、`zsh/`、`cursor/`、`ghostty/`、`mise/` 等 | 各工具**真实配置**，由对应 `*-init` 软链到系统路径 |
| `Makefile.scripts` | `make <script-name>` 运行 `script/<name>.sh` |

## 脚本命名

- **`*-install.sh`**：安装软件/运行时（如 `docker-install`、`nvim-install`、`mise-install`）
- **`*-init.sh`**：把 dotfile 配置**软链接**到系统默认路径（如 `git-init`、`fish-init`、`nvim-init`）
- **工具脚本**：动词或名词（`dns-clean`、`scan-ip`、`nosudo`、`docker-group`、`dirsize`）
- 文件名与 `make` / `ff script` 子命令一致（无扩展名调用）

## 新增脚本 checklist

1. 放在 `script/`，shebang + **一行 `#` 功能描述**（供 `ff script -h` 自动展示）
2. `source "$SCRIPT_DIR/common/help.sh"`，实现 `usage()`，支持 **`-h` / `--help`**
3. 需要平台判断时用 `script/common/os-arch.sh`
4. 依赖国内镜像的安装脚本读取 **`CN_REGION=1`**（`toggle-region` / `ff region`）
5. 若需 fish 补全，更新 `fish/completions/ff.fish`（描述从脚本头注释提取）

## init 脚本模式

- 目标路径已有文件：**先备份**（`*.bak` 或 `*.backup.<timestamp>`），再 `ln -sf` 指向 `~/.dotfile/...`
- 已存在且指向正确的软链：**幂等跳过**
- 示例：`git-init` → `~/.gitconfig`；`nvim-init` → `~/.config/nvim`；`ghostty-init` → 各平台 Ghostty 配置目录
- **fish-init** 特殊：不链整个 `config.fish`，只在顶部插入 `source ~/.dotfile/fish/default.fish`，并链 `functions/`、`completions/`

## install 脚本模式

- 优先用系统包管理器（brew/apt），其次官方安装脚本或 Release 二进制到 `~/.local/bin`
- Debian/Ubuntu 安装类脚本应支持 `CN_REGION` 切换镜像（参考 `docker-install.sh`）
- 需要 root 的脚本在 usage 里写 `sudo`，不要静默假设

## Fish / `ff` 入口

- 跑脚本：`ff script <name>` 或 `ff s <name>`（走 `execute-script.fish`）
- 列脚本：`ff script -h`
- 新增 `ff` 子命令时：改 `fish/functions/ff.fish` + `fish/completions/ff.fish`

## Git 配置

- 公共配置在 `git/.gitconfig`
- **凭据**（所有 Git 版本）：`git/git-credential.sh` 写在主配置里，使用 `!$HOME/.dotfile/...`（Git 不展开 `~`）
  - macOS：`osxkeychain` → 回退 `store`（`~/.git-credentials`）
  - Linux：`libsecret` → 回退 `store`
- 平台扩展（可选）：`git/.gitconfig.darwin` / `.gitconfig.linux` 仅在高版本 Git 下通过 includeIf 加载
- `help.autocorrect`：主配置为 `0`（兼容旧 Git）；Git ≥ 2.36 的平台文件里为 `prompt`

## 边界（不要做的事）

- 不要把密钥、webhook、本机专用路径写进 git（`script/clash.sh` 等已在 `.gitignore`）
- 不要改 `~/.config/fish/config.fish` 进仓库；本机差异放 `custom.fish`
- 不要为 init 复制整份配置到 `$HOME`；**优先软链接**到 dotfile
- 脚本改动保持最小 diff，风格与相邻脚本一致（bash、`set -euo pipefail` 视情况）
- 未经明确要求不要 `git commit` / `git push`

## 参考模板（新 bash 脚本）

```bash
#!/bin/bash
# 一行功能描述

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: ...
选项:
  -h, --help  显示此帮助
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help
# ... 正文
```
