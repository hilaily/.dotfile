function _notify_emit --argument-names title body
    if set -q TMUX
        printf '\ePtmux;\e\e]777;notify;%s;%s\a\e\\' "$title" "$body"
    else
        printf '\e]777;notify;%s;%s\a' "$title" "$body"
    end
end
