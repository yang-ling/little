#!/usr/bin/env bash
export XDG_CONFIG_HOME=$HOME/.config
export NOTMUCH_CONFIG=$XDG_CONFIG_HOME/notmuch/notmuch-config
export GNUPGHOME=$XDG_CONFIG_HOME/gnupg

NOTMUCH_LOCKFILE=/tmp/notmuch-lockfile

notmuch_command=/usr/bin/notmuch
dotlockfile_command=/usr/bin/dotlockfile
notify_send_command=/usr/bin/notify-send
perl_command=/usr/bin/perl
mbsync_command=/usr/bin/mbsync
offlineimap_command=/usr/bin/offlineimap

function sendWarning {
    echo "$2"
    $notify_send_command -t 5000 -u critical "$1" "$2"
}

function lock_notmuch {
    retry_count=${1:-10}
    echo "Check lockfile $NOTMUCH_LOCKFILE"
    $dotlockfile_command -l -r $retry_count -p "$NOTMUCH_LOCKFILE"
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
