#!/usr/bin/env bash
export XDG_CONFIG_HOME=$HOME/.config
export NOTMUCH_CONFIG=$XDG_CONFIG_HOME/notmuch/notmuch-config

NOTMUCH_LOCKFILE=/tmp/notmuch-lockfile

function sendWarning {
    echo "$2"
    notify-send -t 5000 -u critical "$1" "$2"
}

function lock_notmuch {
    retry_count=${1:-10}
    echo "Check lockfile $NOTMUCH_LOCKFILE"
    dotlockfile -r $retry_count -l -p "$NOTMUCH_LOCKFILE"
    if [[ $? -ne 0 ]]; then
        sendWarning "My Notmuch Locker" "Notmuch is in use!"
        return 1
    fi
    echo "Lockfile check OK!"
    return 0
}

function unlock_notmuch {
    echo "Unlock lockfile $NOTMUCH_LOCKFILE!"
    dotlockfile -u "$NOTMUCH_LOCKFILE"
    echo "Unlock lockfile $NOTMUCH_LOCKFILE finished!"
}
