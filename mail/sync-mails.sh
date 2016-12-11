#!/usr/bin/env bash

sendWarning() {
    echo "$2"
    notify-send -t 5000 -u critical "$1" "$2"
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
remaining_retry_count=$(( max_retry_count - retry_count ))

check_retry() {
    retry_count=$(( retry_count+1 ))
    [[ $retry_count -lt $max_retry_count ]] || { sendWarning "Sync Mail" "No retry available! Exit with error!"; exit 1; }
    remaining_retry_count=$(( max_retry_count - retry_count ))
    sendWarning "Sync Mail" "Tried $retry_count times, and $remaining_retry_count tries are available. Continue..."
}

main() {
    echo "Start Sync Mails!"
    notify-send "Start Sync Mails!"

    while true ; do
        round=$(( round+1 ))
        echo "Round $round started!"
        echo "Tried $retry_count times, and $remaining_retry_count tries are available. Continue..."
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

        echo "Start notmuch new!"
        notmuch new
        echo "Finish notmuch new!"

        echo "Unlock lockfile!"
        dotlockfile -u "$LOCKFILE"
        echo "Unlock lockfile finished!"
    done
}

main | adddate >> "$HOME/.sync-mail-log/sync-mails-$(date +'%F-%H-%M-%S')" 2>&1
