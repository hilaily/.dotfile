function pwdc --description 'Copy current directory path to clipboard'
    set -l dir (pwd -P)
    if not printf '%s' $dir | clip-copy.sh
        return 1
    end
    echo "Copied: "(string replace $HOME '~' $dir)
end
