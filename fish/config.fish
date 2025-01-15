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

# set environment
set paths_to_check /usr/sbin /usr/local/bin /usr/bin /bin /usr/sbin /sbin /opt/bin /opt/sbin /usr/syno/sbin /usr/syno/bin /usr/local/sbin $HOME/.local/bin
for path in $paths_to_check
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
add_to_path $HOME/go/bin
add_to_path $HOME/.yarn/bin $HOME/.config/yarn/global/node_modules/.bin


#################################################################
# node
add_to_path /usr/local/node/bin


#################################################################
# python
set -gx PYENV_ROOT $HOME/.pyenv
# Pyenv initialization
if command -v pyenv 1>/dev/null 2>&1
    pyenv init - | source
end

add_to_path $PYENV_ROOT/bin


#################################################################
# nvim
add_to_path usr/local/nvim/bin /usr/local/osx-64/nvim/bin
set -gx EDITOR vim
function gtr
    go test -gcflags=all=-l -v -run=$argv
end


#################################################################
# git
# alias 
alias gitb="git branch --show-current | tr -d '\n' | pbcopy"
alias gci="golangci-lint run -c=~/.dotfile/.golangci.yml ./..."
alias gmt="go mod tidy"
alias gtc="go test -gcflags=all=-l -cover ./..."
alias swg="swag init -o docs -g "
alias sws="swagger serve -F=swagger"
alias sourceit="source ~/.config/fish/config.fish"


#################################################################
# docker
function dc
    # 检查 docker-compose 是否可用
    if command -v docker-compose > /dev/null
        set compose_cmd "docker-compose"
    else
        set compose_cmd "docker compose"
    end

    switch $argv[1]
        case 'build'
            $compose_cmd build $argv[2..-1]
        case 'run'
            $compose_cmd run $argv[2..-1]
        case 'exec'
            $compose_cmd exec $argv[2..-1]
        case 'l'
            $compose_cmd logs $argv[2..-1]
        case 'lf'
            $compose_cmd logs -f $argv[2..-1]
        case 'restart'
            $compose_cmd restart $argv[2..-1]
        case 'rm'
            $compose_cmd rm $argv[2..-1]
        case 'pull'
            $compose_cmd pull $argv[2..-1]
        case 'stop'
            $compose_cmd stop $argv[2..-1]
        case 'kill'
            $compose_cmd kill $argv[2..-1]
        case 'pause'
            $compose_cmd pause $argv[2..-1]
        case 'unpause'
            $compose_cmd unpause $argv[2..-1]
        case 'rup'
            $compose_cmd up -d --force-recreate $argv[2..-1]
        case 'up'
            $compose_cmd up -d $argv[2..-1]
        case 'down'
            $compose_cmd down $argv[2..-1]
        case '*'
            $compose_cmd $argv
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

# reload conf
function fre
    source ~/.config/fish/config.fish
    echo "Fish configuration updated!"
end

function refish
    source ~/.config/fish/config.fish
    echo "Fish configuration updated!"
end



# vi config
alias fvi="vim ~/.config/fish/custom.fish"
# cd config
alias fcd="cd ~/.config/fish/"

function punset
    set -e http_proxy
    set -e https_proxy
    set -e ftp_proxy
    set -e all_proxy
    set -e HTTP_PROXY
    set -e HTTPS_PROXY
    set -e FTP_PROXY
    set -e ALL_PROXY
    echo "Proxy environment variables have been reset."
    pshow
end

function pshow
    export | grep -i proxy
end

function pset
    set -gx https_proxy http://127.0.0.1:7890
    set -gx http_proxy http://127.0.0.1:7890
    set -gx all_proxy socks5://127.0.0.1:7890
    echo "Proxy environment variables have been set."
    pshow
end
