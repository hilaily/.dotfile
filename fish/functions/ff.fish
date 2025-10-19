# Fast commands management
function ff
    # 定义命令和描述（格式：命令|描述）
    set -l commands \
        "reload|Reload fish configuration" \
        "edit|Edit custom fish configuration" \
        "cd|Change to fish config directory" \
        "pon|Enable proxy (proxy on)" \
        "poff|Disable proxy (proxy off)" \
        "pst|Show proxy status" \
        "make|Run dotfile Makefile commands" \
        "help|Show this help message"
    
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
        case '*'
            if test -z "$argv[1]"
                echo "Error: No command specified"
            else
                echo "Error: Unknown command '$argv[1]'"
            end
            echo "Run 'ff help' for usage information"
    end
end

