# CN_REGION 持久化到 ~/.config/fish/custom.fish（供 toggle-region / ff region 使用）

dotfile_region_custom_fish() {
    echo "${HOME}/.config/fish/custom.fish"
}

dotfile_region_read() {
    local custom val
    custom="$(dotfile_region_custom_fish)"
    if [ -f "$custom" ]; then
        val=$(
            grep -E '^[[:space:]]*set[[:space:]]+-gx[[:space:]]+CN_REGION[[:space:]]+' "$custom" 2>/dev/null |
                tail -1 |
                awk '{print $NF}'
        )
        if [ -n "$val" ]; then
            echo "$val"
            return 0
        fi
    fi
    if [ -n "${CN_REGION:-}" ]; then
        echo "$CN_REGION"
    else
        echo "0"
    fi
}

dotfile_region_write() {
    local val="$1"
    local custom tmp
    custom="$(dotfile_region_custom_fish)"
    mkdir -p "$(dirname "$custom")"
    tmp="$(mktemp)"
    if [ -f "$custom" ]; then
        grep -Ev '^[[:space:]]*# dotfile: CN_REGION|^[[:space:]]*set[[:space:]]+-gx[[:space:]]+CN_REGION[[:space:]]+' \
            "$custom" >"$tmp" || true
    else
        : >"$tmp"
    fi
    {
        cat "$tmp"
        if [ -s "$tmp" ]; then
            echo
        fi
        echo "# dotfile: CN_REGION (managed by ff region / toggle-region)"
        echo "set -gx CN_REGION ${val}"
    } >"${custom}.new"
    mv "${custom}.new" "$custom"
    rm -f "$tmp"
}

dotfile_region_toggle() {
    local current next
    current="$(dotfile_region_read)"
    if [ "$current" = "1" ]; then
        next=0
    else
        next=1
    fi
    dotfile_region_write "$next"
    export CN_REGION="$next"
    echo "$next"
}

dotfile_region_label() {
    if [ "$1" = "1" ]; then
        echo "国内"
    else
        echo "国外"
    fi
}
