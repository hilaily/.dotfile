# Completions for ff command
complete -c ff -f
set -l ff_subcommands reload edit cd pon poff pst make help
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "reload" -d "Reload fish configuration"
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "edit" -d "Edit custom fish configuration"
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "cd" -d "Change to fish config directory"
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "pon" -d "Enable proxy (proxy on)"
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "poff" -d "Disable proxy (proxy off)"
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "pst" -d "Show proxy status"
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "make" -d "Run dotfile Makefile commands"
complete -c ff -n "not __fish_seen_subcommand_from $ff_subcommands" -a "help" -d "Show this help message"

# make 子命令的补全 - 直接使用脚本文件名
complete -c ff -n "__fish_seen_subcommand_from make" -a "help" -d "Show all make targets"
complete -c ff -n "__fish_seen_subcommand_from make" -a "list" -d "List all available scripts"

# Install scripts
complete -c ff -n "__fish_seen_subcommand_from make" -a "brew-install" -d "Install Homebrew"
complete -c ff -n "__fish_seen_subcommand_from make" -a "docker-install" -d "Install Docker"
complete -c ff -n "__fish_seen_subcommand_from make" -a "nvim-install" -d "Install Neovim"
complete -c ff -n "__fish_seen_subcommand_from make" -a "python-install" -d "Install Python"
complete -c ff -n "__fish_seen_subcommand_from make" -a "gvm-install" -d "Install Go Version Manager"
complete -c ff -n "__fish_seen_subcommand_from make" -a "firacode-install" -d "Install FiraCode font"
complete -c ff -n "__fish_seen_subcommand_from make" -a "font-install" -d "Install fonts"

# Init scripts
complete -c ff -n "__fish_seen_subcommand_from make" -a "fish-init" -d "Initialize Fish shell"
complete -c ff -n "__fish_seen_subcommand_from make" -a "git-init" -d "Initialize Git config"
complete -c ff -n "__fish_seen_subcommand_from make" -a "nvim-init" -d "Initialize Neovim config"
complete -c ff -n "__fish_seen_subcommand_from make" -a "tmux-init" -d "Initialize Tmux config"
complete -c ff -n "__fish_seen_subcommand_from make" -a "cursor-init" -d "Initialize Cursor config"
complete -c ff -n "__fish_seen_subcommand_from make" -a "init-default-user" -d "Initialize default user (sudo)"

# Clean scripts
complete -c ff -n "__fish_seen_subcommand_from make" -a "brew-clean" -d "Clean Homebrew cache"
complete -c ff -n "__fish_seen_subcommand_from make" -a "docker-clean" -d "Clean Docker resources"

# Utils
complete -c ff -n "__fish_seen_subcommand_from make" -a "croncheck" -d "Check cron status"

