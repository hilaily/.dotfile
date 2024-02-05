## set environment

# brew
set -gx HOMEBREW_BREW_GIT_REMOTE "https://mirrors.ustc.edu.cn/brew.git"
set -gx HOMEBREW_CORE_GIT_REMOTE "https://mirrors.ustc.edu.cn/homebrew-core.git"
set -gx HOMEBREW_BOTTLE_DOMAIN "https://mirrors.ustc.edu.cn/homebrew-bottles"

# go
set -gx GOPATH $HOME/go:$HOME/workrepo/go
set -gx GOPROXY goproxy.cn
set -gx GOSUMDB "sum.golang.google.cn"

set -gx PATH $PATH $HOME/go/bin 
set -gx PATH $PATH $HOME/.yarn/bin $HOME/.config/yarn/global/node_modules/.bin
set -gx PATH $PATH "/usr/local/sbin"
# add nvim
set -gx PATH $PATH /usr/local/nvim/bin /usr/local/osx-64/nvim/bin 
set -gx EDITOR vim

# alias 
# git
abbr -a gitb "git branch --show-current | tr -d '\n' | pbcopy"
abbr -a gci "golangci-lint run -c=~/.dotfile/.golangci.yml ./..."
abbr -a gmt "go mod tidy"
abbr -a gtc "go test -gcflags=all=-l -cover ./..."
abbr -a swg "swag init -o docs -g "
abbr -a sws "swagger serve -F=swagger"

function gtr
  go test -gcflags=all=-l -v -run="$1"
end









if status is-interactive
    # Commands to run in interactive sessions can go here
end
