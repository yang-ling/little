#!/usr/bin/env bash
export XDG_CONFIG_HOME=$HOME/.config
export NOTMUCH_CONFIG=$XDG_CONFIG_HOME/notmuch/notmuch-config
export PATH= /usr/local/sbin:/usr/local/bin:/usr/bin:/usr/local/bin
NOTMUCH_LOCKFILE=/tmp/notmuch-lockfile

notmuch_command=$(which notmuch)
dotlockfile_command=$(which dotlockfile)
notify_send_command=$(which notify-send)
perl_command=$(which perl)
mbsync_command=$(which mbsync)
offlineimap_command=$(which offlineimap)

function sendWarning {
    echo "$2"
    $notify_send_command -t 5000 -u critical "$1" "$2"
}

function lock_notmuch {
    retry_count=${1:-10}
    echo "Check lockfile $NOTMUCH_LOCKFILE"
    $dotlockfile_command -r $retry_count -l -p "$NOTMUCH_LOCKFILE"
    if [[ $? -ne 0 ]]; then
        sendWarning "My Notmuch Locker" "Notmuch is in use!"
        return 1
    fi
    echo "Lockfile check OK!"
    return 0
}

function unlock_notmuch {
    echo "Unlock lockfile $NOTMUCH_LOCKFILE!"
    $dotlockfile_command -u "$NOTMUCH_LOCKFILE"
    echo "Unlock lockfile $NOTMUCH_LOCKFILE finished!"
}
