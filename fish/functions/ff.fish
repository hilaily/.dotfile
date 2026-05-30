# Fast commands management
function ff
    # 定义命令和描述（格式：命令|描述）
    set -l commands \
        "reload|Reload fish configuration" \
        "edit|Edit custom fish configuration" \
        "fish|Change to fish config directory" \
        "dotfile|Change to dotfile directory" \
        "pon|Enable proxy (proxy on)" \
        "poff|Disable proxy (proxy off)" \
        "pst|Show proxy status" \
        "make|Run dotfile Makefile commands" \
        "script|Run script from script directory" \
        "update|Update dotfile" \
        "region|Toggle or set CN_REGION (mirror/proxy region)" \
        "ssh|SSH init (keys + config.d) or copy config to remote" \
        "dirsize|Show directory sizes (du wrapper)" \
        "help|Show this help message"

    # 确保 execute-script 可用（在 fish 自动加载前手动引入一次）
    if not functions -q execute-script
        set -l execute_script_path ~/.dotfile/fish/functions/execute-script.fish
        if test -f $execute_script_path
            source $execute_script_path
        end
    end

    switch $argv[1]
        case reload
            source ~/.config/fish/config.fish
            echo "Fish configuration reloaded!"
        case edit
            vim ~/.config/fish/custom.fish
        case fish
            cd ~/.config/fish/
        case dotfile
            cd ~/.dotfile
        case pon
            set -gx https_proxy http://127.0.0.1:7890
            set -gx http_proxy http://127.0.0.1:7890
            set -gx all_proxy socks5://127.0.0.1:7890
            echo "✓ Proxy enabled"
            export | grep -i proxy
        case poff
            set -e http_proxy
            set -e https_proxy
            set -e ftp_proxy
            set -e all_proxy
            set -e HTTP_PROXY
            set -e HTTPS_PROXY
            set -e FTP_PROXY
            set -e ALL_PROXY
            echo "✓ Proxy disabled"
            export | grep -i proxy
        case pst
            export | grep -i proxy
        case make
            # 切换到 dotfile 目录执行脚本管理 makefile
            set -l dotfile_dir ~/.dotfile
            if test -d $dotfile_dir
                make -f $dotfile_dir/Makefile.scripts -C $dotfile_dir $argv[2..-1]
            else
                echo "Error: Dotfile directory not found at $dotfile_dir"
            end
        case script
            if not functions -q execute-script
                source ~/.dotfile/fish/functions/execute-script.fish
            end
            execute-script $argv[2..-1]
        case s
            if not functions -q execute-script
                source ~/.dotfile/fish/functions/execute-script.fish
            end
            execute-script $argv[2..-1]
        case help
            echo "Usage: ff <command>"
            echo ""
            echo "Commands:"
            # 自动生成帮助信息
            for cmd in $commands
                set -l parts (string split '|' $cmd)
                printf "  %-10s %s\n" $parts[1] $parts[2]
            end
        case update
            cd ~/.dotfile
            git pull origin main
            cd -
        case ssh
            if not functions -q ff_ssh
                source ~/.dotfile/fish/functions/ff-ssh.fish
            end
            ff_ssh $argv[2..-1]
        case dirsize
            set -l script_path ~/.dotfile/script/dirsize.sh
            if test -f $script_path
                bash $script_path $argv[2..-1]
            else
                echo "Error: dirsize script not found at $script_path"
                return 1
            end
        case region
            set -l sub toggle
            if test (count $argv) -ge 2
                set sub $argv[2]
            end
            switch $sub
                case toggle
                    if test "$CN_REGION" = "1"
                        set -gx CN_REGION 0
                        echo "Switched to: 0 (国外)"
                    else
                        set -gx CN_REGION 1
                        echo "Switched to: 1 (国内)"
                    end
                case '*'
                    echo "Usage: ff region [toggle]"
                    echo "Unknown subcommand: $sub"
            end
        case '*'
            if test -z "$argv[1]"
                echo "Error: No command specified"
            else
                echo "Error: Unknown command '$argv[1]'"
            end
            echo "Run 'ff help' for usage information"
    end
end
