function notify --description '发送 OSC 777 通知；无参时复用上一条命令的状态与耗时'
    set -l rc $status
    set -l dur $CMD_DURATION

    set -l label
    if test (count $argv) -gt 0
        set label (string join ' ' $argv)
    else if test $rc -eq 0
        set label "完成"
    else
        set label "失败 exit=$rc"
    end

    set -l body (_notify_human_duration $dur)" · "(hostname -s)" · "(pwd | string replace $HOME '~')

    _notify_emit "$label" "$body"
    return $rc
end
