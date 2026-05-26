function notify-done --description '前置包装：运行命令并在完成时发送 OSC 777 通知'
    if test (count $argv) -eq 0
        echo "Usage: notify-done <command> [args...]" >&2
        return 2
    end

    set -l start (date +%s)
    $argv
    set -l rc $status
    set -l elapsed (math (date +%s) - $start)
    set -l human (_notify_human_duration (math $elapsed \* 1000))

    set -l label
    if test $rc -eq 0
        set label "完成: $argv[1]"
    else
        set label "失败 exit=$rc: $argv[1]"
    end

    set -l body "$human · "(hostname -s)" · "(string join ' ' $argv)

    _notify_emit "$label" "$body"
    return $rc
end
