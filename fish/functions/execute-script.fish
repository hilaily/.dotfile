# Execute script from script directory
function execute-script
    if not functions -q script-show-catalog
        source ~/.dotfile/fish/functions/script-catalog.fish
    end

    set -l dotfile_dir ~/.dotfile
    set -l script_dir $dotfile_dir/script
    set -l script_name $argv[1]

    # ff script -h / --help / help
    if test -z "$script_name"; or contains -- $script_name -h --help help
        if test -z "$script_name"; or test (count $argv) -eq 1
            script-show-catalog
            return 0
        end
    end

    if test -z "$script_name"
        script-show-catalog
        return 1
    end

    set -l script_path (script-resolve-path $script_name 2>/dev/null; or echo "")

    if test -n "$script_path" -a -f "$script_path"
        echo "Running: $script_path"
        if test -x $script_path
            $script_path $argv[2..-1]
        else if string match -q "*.py" $script_path
            python3 $script_path $argv[2..-1]
        else
            bash $script_path $argv[2..-1]
        end
        return $status
    end

    echo "Error: Script not found: $script_name"
    echo ""
    script-show-catalog
    return 1
end
