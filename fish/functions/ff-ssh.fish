# ff ssh: local init (keys + config.d) and copy config to remote

function __ff_ssh_has_key
    for f in $HOME/.ssh/id_*
        if test -f $f; and not string match -q '*.pub' -- $f
            return 0
        end
    end
    return 1
end

function __ff_ssh_ensure_keys
    if __ff_ssh_has_key
        echo "SSH key exists, skip generation"
        return 0
    end

    set -l key_path "$HOME/.ssh/id_ed25519"
    set -l comment "$USER@"(hostname -s 2>/dev/null; or echo localhost)
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    echo "No SSH key found, generating ed25519: $key_path"
    if test -t 0
        ssh-keygen -t ed25519 -f $key_path -C $comment
    else
        ssh-keygen -t ed25519 -f $key_path -C $comment -N ""
        echo "Non-interactive mode: created with empty passphrase"
    end
end

function __ff_ssh_ensure_config_d
    set -l ssh_config "$HOME/.ssh/config"
    set -l include_line "Include ~/.ssh/config.d/*"
    mkdir -p "$HOME/.ssh/config.d"
    chmod 700 "$HOME/.ssh"

    if not test -f $ssh_config
        printf '%s\n' $include_line > $ssh_config
        chmod 600 $ssh_config
        echo "Created $ssh_config with $include_line"
    else if grep -qE 'Include[[:space:]]+.*config\.d' $ssh_config
        echo "config.d Include already in $ssh_config"
    else
        printf '\n# config.d\n%s\n' $include_line >> $ssh_config
        echo "Appended to $ssh_config: $include_line"
    end
end

function __ff_ssh_resolve_path --argument path
    if test -L $path
        set path (readlink $path)
        if not string match -q '/*' -- $path
            set path "$HOME/.ssh/$path"
        end
    end
    echo $path
end

function __ff_ssh_remote_has_include --argument host
    ssh -q $host 'test -f ~/.ssh/config && grep -qE "Include[[:space:]]+.*config\.d" ~/.ssh/config'
end

function __ff_ssh_remote_ensure_include --argument host
    ssh $host 'mkdir -p ~/.ssh/config.d && chmod 700 ~/.ssh
        if [ -f ~/.ssh/config ] && grep -qE "Include[[:space:]]+.*config\.d" ~/.ssh/config; then
            echo "Remote config.d Include already exists"
        elif [ -f ~/.ssh/config ]; then
            printf "\n# config.d\nInclude ~/.ssh/config.d/*\n" >> ~/.ssh/config
            chmod 600 ~/.ssh/config
            echo "Appended config.d Include on remote"
        else
            printf "%s\n" "Include ~/.ssh/config.d/*" > ~/.ssh/config
            chmod 600 ~/.ssh/config
            echo "Created remote config with config.d Include"
        fi'
end

function __ff_ssh_resolve_copy_src --argument file
    set -l src $file
    if test -f $src
        echo $src
        return 0
    end
    set -l in_config_d "$HOME/.ssh/config.d/$file"
    if test -f $in_config_d
        echo $in_config_d
        return 0
    end
    set -l dotfile_src "$HOME/.dotfile/ssh/config.d/$file"
    if test -f $dotfile_src
        echo $dotfile_src
        return 0
    end
    return 1
end

function __ff_ssh_copy_remote --argument-names argv
    set -l host $argv[1]
    set -l files $argv[2..-1]
    set -l ssh_dir "$HOME/.ssh"
    set -l main_config "$ssh_dir/config"

    if test -z "$host"
        echo "Usage: ff ssh copy <host> <config-file>..."
        echo "  host:  SSH alias or user@hostname"
        echo "  file:  path, or name under ~/.ssh/config.d/"
        return 1
    end

    if test (count $files) -eq 0
        echo "Usage: ff ssh copy <host> <config-file>..."
        echo ""
        echo "Examples:"
        echo "  ff ssh copy mynas 30-hanxi.conf"
        echo "  ff ssh copy mynas ~/.dotfile/ssh/config.d/20-personal.conf"
        if test -d "$ssh_dir/config.d"
            echo ""
            echo "Available in ~/.ssh/config.d/:"
            ls -1 "$ssh_dir/config.d/"
        end
        return 1
    end

    echo "Checking remote Include on $host ..."
    ssh -q $host "mkdir -p ~/.ssh/config.d && chmod 700 ~/.ssh"

    if __ff_ssh_remote_has_include $host
        echo "Remote config.d Include: OK"
    else
        echo "Remote missing config.d Include, adding ..."
        __ff_ssh_remote_ensure_include $host
    end

    for f in $files
        set -l src (__ff_ssh_resolve_copy_src $f 2>/dev/null)
        if test $status -ne 0 -o -z "$src"
            echo "Error: file not found: $f"
            return 1
        end

        set -l resolved_main (__ff_ssh_resolve_path $main_config)
        set -l name (basename $src)

        if test "$src" = "$resolved_main"; or test "$name" = config
            set -l ts (date +%Y%m%d%H%M%S)
            ssh -q $host "test -f ~/.ssh/config && cp ~/.ssh/config ~/.ssh/config.bak.$ts || true"
            scp -q $src "$host:.ssh/config"
            ssh -q $host "chmod 600 ~/.ssh/config"
            echo "Copied $src -> $host:~/.ssh/config"
        else
            scp -q $src "$host:.ssh/config.d/$name"
            ssh -q $host "chmod 600 ~/.ssh/config.d/$name"
            echo "Copied $src -> $host:~/.ssh/config.d/$name"
        end
    end

    echo "Done."
end

function ff_ssh --argument-names argv
    set -l sub (test (count $argv) -ge 1; and echo $argv[1]; or echo init)

    switch $sub
        case init ''
            __ff_ssh_ensure_keys
            __ff_ssh_ensure_config_d
        case copy
            __ff_ssh_copy_remote $argv[2..-1]
        case help -h
            echo "Usage: ff ssh [init|copy <host> <file>...|help]"
            echo ""
            echo "  init                Ensure SSH key and config.d Include (default)"
            echo "  copy <host> <file>  Check remote Include, then scp specified config file(s)"
            echo "  help                Show this help"
        case '*'
            echo "Unknown subcommand: $sub"
            echo "Run 'ff ssh help' for usage"
            return 1
    end
end
