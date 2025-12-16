#################################################################
# option
fish_vi_key_bindings

#################################################################
# basic 
# 定义一个函数来检查并添加路径到 PATH
function add_to_path
    # 遍历传递给函数的所有参数
    for path in $argv
        # 检查路径是否存在
        if test -d $path
            # 如果路径存在且不在 PATH 中，则添加到 PATH
            if not contains $path $PATH
                #echo "Adding $path to PATH"
                set -gx PATH $PATH $path
            else
                #echo "$path is already in PATH"
            end
        else
            #echo "$path does not exist"
        end
    end
end

function is_command_exists
    if command -v $argv[1] >/dev/null 2>&1
        return 0
    else
        return 1
    end
end

# set environment
set paths_to_check /usr/sbin /usr/local/bin /usr/bin /bin /usr/sbin /sbin /opt/bin /opt/sbin /usr/syno/sbin /usr/syno/bin /usr/local/sbin $HOME/.local/bin
for path in $paths_to_check do
    add_to_path $path
end

function sudoo
    eval sudo $history[1]
end

# add my script
add_to_path $HOME/.dotfile/script $HOME/.app00/script

if test -f ~/.config/fish/custom.fish
    source ~/.config/fish/custom.fish
end

#################################################################
# brew
set -gx HOMEBREW_BREW_GIT_REMOTE "https://mirrors.ustc.edu.cn/brew.git"
set -gx HOMEBREW_CORE_GIT_REMOTE "https://mirrors.ustc.edu.cn/homebrew-core.git"
set -gx HOMEBREW_BOTTLE_DOMAIN "https://mirrors.ustc.edu.cn/homebrew-bottles"

#################################################################
# go
set -gx GOPATH $HOME/go:$HOME/workrepo/go
set -gx GOPROXY "goproxy.cn,direct"
set -gx GOSUMDB "sum.golang.google.cn"
set -gx EDITOR vim
add_to_path $HOME/go/bin
add_to_path $HOME/.yarn/bin $HOME/.config/yarn/global/node_modules/.bin
function gtr
    go test -gcflags=all=-l -v -run=$argv
end

#################################################################
# python
set -gx PYENV_ROOT $HOME/.pyenv
# Pyenv initialization
if command -v pyenv 1>/dev/null 2>&1
    pyenv init - | source
end

add_to_path $PYENV_ROOT/bin

#################################################################
# node
# add_to_path /usr/local/node/bin
# add_to_path usr/local/nvim/bin /usr/local/osx-64/nvim/bin

# fnm
set FNM_PATH "$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]
    set PATH "$FNM_PATH" $PATH
    alias nvm="fnm"
    fnm env --use-on-cd --shell fish | source
end

# pnpm
set -gx PNPM_HOME $HOME/.pnpm
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end

#################################################################
# git
# alias 
alias gitb="git branch --show-current | tr -d '\n' | pbcopy"
alias gci="golangci-lint run -c=~/.dotfile/golang/golangci.yml ./..."
alias gmt="go mod tidy"
alias gtc="go test -gcflags=all=-l -cover ./..."
alias swg="swag init -o docs -g "
alias sws="swagger serve -F=swagger"
alias sourceit="source ~/.config/fish/config.fish"

#################################################################
# docker
function dc
    # 检查第一个参数是否是 is_sudo
    set use_sudo false
    set args $argv
    
    if test (count $argv) -gt 0; and test "$argv[1]" = "is_sudo"
        set use_sudo true
        set args $argv[2..-1]
    end
    
    # 检查 docker-compose 是否可用
    if command -v docker-compose >/dev/null
        set compose_cmd docker-compose
    else
        set compose_cmd docker compose
    end
    
    # 构建执行命令（如果需要 sudo，添加 sudo 前缀）
    if test $use_sudo = true
        set exec_cmd command sudo $compose_cmd
    else
        set exec_cmd $compose_cmd
    end

    switch $args[1]
        case lf
            $exec_cmd logs -f $args[2..-1]
        case upd
            $exec_cmd up -d $args[2..-1] && $exec_cmd logs -f $args[2..-1]
        case reupd
            $exec_cmd up -d --force-recreate $args[2..-1] && $exec_cmd logs -f $args[2..-1]
        case '*'
            $exec_cmd $args
    end
end

#################################################################
# systemctl
function sc
    systemctl $argv
end

function jc
    journalctl $argv
end

# 智能 sudo 包装，支持展开函数别名
function sudo --wraps sudo
    if test (count $argv) -gt 0
        set cmd $argv[1]
        switch $cmd
            case sc
                command sudo systemctl $argv[2..-1]
            case jc
                command sudo journalctl $argv[2..-1]
            case dc
                # 调用 dc 函数并传递 is_sudo 参数
                dc is_sudo $argv[2..-1]
            case '*'
                command sudo $argv
        end
    else
        command sudo $argv
    end
end

#################################################################
# other
function ctl
    systemctl $argv
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# source env
function source_env
    for line in (cat $argv | grep -v '^#' | grep -v '^\s*$')
        set item (string split -m 1 '=' $line)
        set -gx $item[1] (eval echo $item[2])
    end
end

function make2
    make -f Makefile.local $argv
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
