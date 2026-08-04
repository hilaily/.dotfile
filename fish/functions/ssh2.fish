# ssh-copy-id 后交互保存 SSH Host 别名
function ssh2 --wraps ssh-copy-id --description "Copy SSH key and save host alias"
    set -l script_path ~/.dotfile/script/ssh2.sh
    if not test -f $script_path
        echo "Error: ssh2 script not found at $script_path" >&2
        return 1
    end

    bash $script_path $argv
end
