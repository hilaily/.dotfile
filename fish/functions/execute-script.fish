# Execute script from script directory
function execute-script
    # 执行 script 目录下的脚本
    set -l dotfile_dir ~/.dotfile
    set -l script_dir $dotfile_dir/script
    set -l script_name $argv[1]
    
    if test -z "$script_name"
        echo "Error: No script name specified"
        echo "Usage: execute-script <script_name> [args...]"
        echo ""
        echo "Available scripts:"
        if test -d $script_dir
            for script in $script_dir/*.sh $script_dir/*.py
                if test -f $script
                    set -l basename (basename $script)
                    echo "  $basename"
                end
            end
        end
        return 1
    end
    
    # 尝试不同的扩展名
    set -l script_path ""
    for ext in sh py
        set -l test_path $script_dir/$script_name.$ext
        if test -f $test_path
            set script_path $test_path
            break
        end
    end
    
    # 如果没找到，尝试直接使用提供的名称
    if test -z "$script_path"
        set script_path $script_dir/$script_name
    end
    
    if test -f $script_path
        echo "Running: $script_path"
        if test -x $script_path
            $script_path $argv[2..-1]
        else
            # 根据文件类型选择解释器
            if string match -q "*.py" $script_path
                python3 $script_path $argv[2..-1]
            else
                bash $script_path $argv[2..-1]
            end
        end
    else
        echo "Error: Script not found: $script_name"
        echo "Available scripts:"
        if test -d $script_dir
            for script in $script_dir/*.sh $script_dir/*.py
                if test -f $script
                    set -l basename (basename $script)
                    echo "  $basename"
                end
            end
        end
        return 1
    end
end

