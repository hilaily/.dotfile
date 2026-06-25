# Oh My Zsh（由 ~/.dotfile/script/zsh-init.sh 安装到 ~/.oh-my-zsh）
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# z：目录跳转频率学习（OMZ 自带 plugins/z）
plugins=(
  git
  z
)

if [[ -d "$ZSH" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  echo "[zsh] Oh My Zsh 未安装，请运行: bash ~/.dotfile/script/zsh-init.sh" >&2
fi

# 复制当前 git 分支名到剪贴板（macOS / Linux）
gitb() {
  git branch --show-current | tr -d '\n' | clip-copy.sh
}

# 复制当前目录到剪贴板（macOS / Linux）
pwdc() {
  local dir
  dir="$(pwd -P)"
  printf '%s' "$dir" | clip-copy.sh || return 1
  echo "Copied: ${dir/#$HOME/~}"
}

# 本机私有配置（不纳入 dotfile）
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
