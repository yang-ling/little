#!/usr/bin/env bash
export XDG_CONFIG_HOME=$HOME/.config
export NOTMUCH_CONFIG=$XDG_CONFIG_HOME/notmuch/notmuch-config

NOTMUCH_LOCKFILE=/tmp/notmuch-lockfile

function sendWarning {
    echo "$2"
    notify-send -t 5000 -u critical "$1" "$2"
}

function lock_notmuch {
    wait_time=$1
    retry_count=$2
    lock_success=0
    while [[ $lock_success -eq 0 ]] && [[ retry_count -gt 0 ]]; do
        echo "Check lockfile $NOTMUCH_LOCKFILE"
        dotlockfile -r 10 -l -p "$NOTMUCH_LOCKFILE"
        if [[ $? -eq 0 ]]; then
            lock_success=1
        else
            lock_success=0
            retry_count=$(( retry_count-1 ))
            sleep $wait_time
        fi
    done

    [[ $lock_success -eq 0 ]] && { sendWarning "My Notmuch Locker" "Notmuch is in use!"; return 1; }
    echo "Lockfile check OK!"
    return 0
}

function unlock_notmuch {
    echo "Unlock lockfile $NOTMUCH_LOCKFILE!"
    dotlockfile -u "$NOTMUCH_LOCKFILE"
    echo "Unlock lockfile $NOTMUCH_LOCKFILE finished!"
}
