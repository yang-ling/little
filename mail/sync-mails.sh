#!/usr/bin/env bash

sendWarning() {
    echo "$2"
    notify-send -t 300000 -u critical "$1" "$2"
}

adddate() {
    while IFS= read -r line; do
        echo "$(date +'%Z %F %T') $line"
    done
}

LOCKFILE=/tmp/sync-mails-dotfile

wait_time=${1:-1m}
max_retry_count=${2:-5}
retry_count=0
round=0

check_retry() {
    retry_count=$(( retry_count+1 ))
    [[ $retry_count -lt $max_retry_count ]] || { sendWarning "Sync Mail" "No retry available! Exit with error!"; exit 1; }
    sendWarning "Sync Mail" "Tried $retry_count times, and $max_retry_count tries in total are available. Continue..."
}

main() {
    echo "Start Sync Mails!"
    notify-send "Start Sync Mails!"

    while true ; do
        round=$(( round+1 ))
        echo "Round $round started!"
        echo "Sleep ${wait_time} at first..."
        sleep ${wait_time}
        echo "Sleep finished!"

        echo "Check lockfile $LOCKFILE"
        dotlockfile -r 10 -l -p "$LOCKFILE"

        [[ $? -ne 0 ]] && { sendWarning "Sync Mail" "Previous sync lasts too long!"; check_retry;}
        echo "Lockfile check OK!"

        echo "Start mbsync!"
        mbsync -c ~/.config/isync/mbsyncrc -a
        [[ $? -ne 0 ]] && { sendWarning "Sync Mail" "mbsync throws error!"; check_retry; }
        echo "Finish mbsync!"

        echo "Start offlineimap!"
        offlineimap -c ~/.config/offlineimap/offlineimap.conf
        [[ $? -ne 0 ]] && { sendWarning "Sync Mail" "offlineimap throws error!"; check_retry; }
        echo "Finish offlineimap!"

        echo "Unlock lockfile!"
        dotlockfile -u "$LOCKFILE"
        echo "Unlock lockfile finished!"
    done
}

main | adddate >> "$HOME/.sync-mail-log/sync-mails-$(date +'%F-%H-%M-%S')" 2>&1
