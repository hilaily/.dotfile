# 列举 ~/.dotfile/script 下脚本及从文件头注释提取的简短说明

function script-extract-description --argument filepath
    if not test -f "$filepath"
        echo "(无描述)"
        return
    end

    set -l past_shebang 0
    set -l candidates
    for line in (cat "$filepath")
        if string match -qr '^#!/' -- $line
            set past_shebang 1
            continue
        end
        if test $past_shebang -eq 0
            continue
        end

        set line (string trim $line)
        if test -z "$line"
            if test (count $candidates) -gt 0
                break
            end
            continue
        end
        if not string match -qr '^#' -- $line
            break
        end

        set line (string replace -r '^#\s*' '' $line)
        if string match -qr '^---' -- $line
            continue
        end
        if string match -qr '^(用法|Usage|示例|Example)' -- $line
            continue
        end
        if string match -qr '^\./' -- $line
            continue
        end
        if string match -qr '^https?://' -- $line
            continue
        end
        # 行内 “# 用法” 类注释
        if string match -qr '#\s*(用法|Usage)' -- $line
            continue
        end

        set candidates $candidates $line
        if test (count $candidates) -ge 8
            break
        end
    end

    if test (count $candidates) -eq 0
        echo "(无描述)"
        return
    end

    for c in $candidates
        if string match -qr '(脚本|安装|初始化|清理|扫描|切换|配置|用于|镜像|凭据|用户组|免密|Install|Init|Clean|Toggle)' -- $c
            echo $c
            return
        end
    end

    for c in $candidates
        if test (string length $c) -ge 10
            echo $c
            return
        end
    end

    echo $candidates[1]
end

function script-list-names
    set -l script_dir ~/.dotfile/script
    set -l names
    if not test -d $script_dir
        return
    end

    for script in $script_dir/*.sh $script_dir/*.py
        if test -f $script
            set -l name (basename $script)
            set name (string replace -r '\.(sh|py)$' '' $name)
            set names $names $name
        end
    end

    string join \n $names | sort
end

function script-resolve-path --argument name
    set -l script_dir ~/.dotfile/script
    for ext in sh py
        set -l path "$script_dir/$name.$ext"
        if test -f $path
            echo $path
            return 0
        end
    end
    if test -f "$script_dir/$name"
        echo "$script_dir/$name"
        return 0
    end
    return 1
end

function script-show-catalog
    set -l script_dir ~/.dotfile/script
    echo "Usage: ff script <name> [args...]  (alias: ff s)"
    echo ""
    echo "Scripts in $script_dir:"
    echo ""

    for name in (script-list-names)
        set -l path (script-resolve-path $name)
        set -l desc (script-extract-description $path)
        printf "  %-22s %s\n" $name $desc
    end

    echo ""
    echo "提示: ff s <name> -h  查看单个脚本内的详细帮助"
end
