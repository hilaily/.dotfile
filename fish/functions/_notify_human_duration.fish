function _notify_human_duration --argument-names ms
    test -z "$ms"; and set ms 0
    set -l s (math --scale=0 $ms / 1000)
    if test $s -lt 1
        echo {$ms}ms
    else if test $s -lt 60
        echo {$s}s
    else if test $s -lt 3600
        echo (math --scale=0 $s / 60)m(math $s % 60)s
    else
        echo (math --scale=0 $s / 3600)h(math --scale=0 ($s % 3600) / 60)m
    end
end
