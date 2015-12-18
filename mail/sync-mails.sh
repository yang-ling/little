#!/usr/bin/env bash

set -x

sendWarning() {
    notify-send -t 300000 -u critical "$1" "$2"
}

LOCKFILE=/tmp/sync-mails-dotfile


echo "Start Sync Mails!"
notify-send "Start Sync Mails!"

while true ; do
    sleep 5m
    dotlockfile -r 10 -l -p "$LOCKFILE"

    [[ $? -ne 0 ]] && { sendWarning "Sync Mail" "Previous sync lasts too long!"; exit 1;}

    mbsync -c ~/.config/isync/mbsyncrc -a
    [[ $? -ne 0 ]] && { sendWarning "Sync Mail" "mbsync throws error!"; exit 1; }

    offlineimap -c ~/.config/offlineimap/offlineimap.conf
    [[ $? -ne 0 ]] && { sendWarning "Sync Mail" "offlineimap throws error!"; exit 1; }

    dotlockfile -u "$LOCKFILE"
done

