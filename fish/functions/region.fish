# CN_REGION 读写 ~/.config/fish/custom.fish（与 script/common/region.sh 约定一致）

function region_custom_path
    echo ~/.config/fish/custom.fish
end

function region_read
    set -l path (region_custom_path)
    if test -f $path
        set -l matches (grep -E '^\s*set\s+-gx\s+CN_REGION\s+' $path 2>/dev/null)
        if test (count $matches) -gt 0
            set -l line $matches[-1]
            echo (string trim (string replace -r '.*\s' '' $line))
            return
        end
    end
    if set -q CN_REGION
        echo $CN_REGION
    else
        echo 0
    end
end

function region_write
    set -l new $argv[1]
    set -l path (region_custom_path)
    mkdir -p (dirname $path)

    set -l tmp (mktemp)
    if test -f $path
        grep -Ev '^\s*# dotfile: CN_REGION|^\s*set\s+-gx\s+CN_REGION\s+' $path >$tmp 2>/dev/null; or true
    else
        touch $tmp
    end
    echo "# dotfile: CN_REGION (managed by ff region / toggle-region)" >>$tmp
    echo "set -gx CN_REGION $new" >>$tmp
    mv $tmp $path

    set -gx CN_REGION $new
end

function region_toggle
    set -l current (region_read)
    set -l new
    if test "$current" = "1"
        set new 0
        echo "Switched to: 0 (国外)"
    else
        set new 1
        echo "Switched to: 1 (国内)"
    end
    region_write $new
    echo "Persisted to ~/.config/fish/custom.fish"
end

function region_apply_from_custom
    set -gx CN_REGION (region_read)
end
