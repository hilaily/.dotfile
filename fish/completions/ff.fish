# Completions for ff command
complete -c ff -f
set -l ff_subcommands reload edit fish dotfile pon poff pst make script s update help region ssh init copy help region
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "reload" -d "Reload fish configuration"
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "edit" -d "Edit custom fish configuration"
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "fish" -d "Change to fish config directory"
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "dotfile" -d "Change to dotfile directory"
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "pon" -d "Enable proxy (proxy on)"
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "poff" -d "Disable proxy (proxy off)"
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "pst" -d "Show proxy status"
# complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "make" -d "Run dotfile Makefile commands"
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "script" -d "Run script from script directory"
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "help" -d "Show this help message"

complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "region" -d "Toggle or set CN_REGION (mirror/proxy region)"
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "ssh" -d "SSH init (keys + config.d) or copy config to remote"

complete -c ff -n "__fish_seen_subcommand_from ssh; and not __fish_seen_subcommand_from init copy help" -a init -d "Ensure SSH key and config.d Include"
complete -c ff -n "__fish_seen_subcommand_from ssh; and not __fish_seen_subcommand_from init copy help" -a copy -d "Copy specified SSH config file(s) to remote"
complete -c ff -n "__fish_seen_subcommand_from ssh; and not __fish_seen_subcommand_from init copy help" -a help -d "Show ssh subcommand help"

function __ff_ssh_config_d_files
    for d in $HOME/.ssh/config.d $HOME/.dotfile/ssh/config.d
        if test -d $d
            for f in $d/*
                if test -f $f
                    basename $f
                end
            end
        end
    end
end

complete -c ff -n "__fish_seen_subcommand_from ssh copy; and test (count (commandline -opc)) -eq 2" -a "(__fish_ssh_hosts 2>/dev/null; or __fish_print_hostnames)" -d "SSH host"
complete -c ff -n "__fish_seen_subcommand_from ssh copy; and test (count (commandline -opc)) -ge 3" -a "(__ff_ssh_config_d_files)" -d "Config file"

# # make 子命令的补全 - 直接使用脚本文件名
# complete -c ff -n "__fish_seen_subcommand_from make" -a "help" -d "Show all make targets"
# complete -c ff -n "__fish_seen_subcommand_from make" -a "list" -d "List all available scripts"

# Install scripts
# complete -c ff -n "__fish_seen_subcommand_from make" -a "brew-install" -d "Install Homebrew"
# complete -c ff -n "__fish_seen_subcommand_from make" -a "docker-install" -d "Install Docker"
# complete -c ff -n "__fish_seen_subcommand_from make" -a "nvim-install" -d "Install Neovim"
# complete -c ff -n "__fish_seen_subcommand_from make" -a "python-install" -d "Install Python"
# complete -c ff -n "__fish_seen_subcommand_from make" -a "gvm-install" -d "Install Go Version Manager"
# complete -c ff -n "__fish_seen_subcommand_from make" -a "firacode-install" -d "Install FiraCode font"
# complete -c ff -n "__fish_seen_subcommand_from make" -a "font-install" -d "Install fonts"

# # Init scripts
# complete -c ff -n "__fish_seen_subcommand_from make" -a "fish-init" -d "Initialize Fish shell"
# complete -c ff -n "__fish_seen_subcommand_from make" -a "git-init" -d "Initialize Git config"
# complete -c ff -n "__fish_seen_subcommand_from make" -a "nvim-init" -d "Initialize Neovim config"
# complete -c ff -n "__fish_seen_subcommand_from make" -a "tmux-init" -d "Initialize Tmux config"
# complete -c ff -n "__fish_seen_subcommand_from make" -a "cursor-init" -d "Initialize Cursor config"
# complete -c ff -n "__fish_seen_subcommand_from make" -a "init-default-user" -d "Initialize default user (sudo)"

# script 子命令的补全 - 动态列出 script 目录下的脚本
function __ff_list_scripts
    set -l script_dir ~/.dotfile/script
    if test -d $script_dir
        # 列出 .sh 文件
        for script in $script_dir/*.sh
            if test -f $script
                basename $script | string replace -r '\.sh$' ''
            end
        end
        # 列出 .py 文件
        for script in $script_dir/*.py
            if test -f $script
                basename $script | string replace -r '\.py$' ''
            end
        end
    end
end

complete -c ff -n "__fish_seen_subcommand_from script" -a '(__ff_list_scripts)' -d "Script name"

