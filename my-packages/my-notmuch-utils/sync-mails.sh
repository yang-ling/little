#!/usr/bin/env bash

source /usr/local/lib/my-notmuch-utils/commons.sh

LOCKFILE=/tmp/sync-mails-dotfile

echo "Start Sync Mails!"

echo "Check lockfile $LOCKFILE"
$dotlockfile_command -r 10 -l -p "$LOCKFILE"

[[ $? -ne 0 ]] && { sendWarning "Sync Mail" "Previous sync lasts too long!"; }
echo "Lockfile check OK!"

echo "Start mbsync!"
$mbsync_command -c ~/.config/isync/mbsyncrc -a
[[ $? -ne 0 ]] && { sendWarning "Sync Mail" "mbsync throws error!"; }
echo "Finish mbsync!"

echo "Start offlineimap!"
$offlineimap_command -c ~/.config/offlineimap/offlineimap.conf
[[ $? -ne 0 ]] && { sendWarning "Sync Mail" "offlineimap throws error!"; }
echo "Finish offlineimap!"

echo "Start notmuch new!"
lock_notmuch 1
if [[ $? -eq 0 ]]; then
    $notmuch_command new
    [[ $? -ne 0 ]] && { sendWarning "Sync Mail" "Notmuch throws error!"; }
    echo "Finish notmuch new!"
else
    sendWarning "Sync Mail" "Notmuch seems to be locked by others"
fi
unlock_notmuch
echo "Finish notmuch new!"

echo "Unlock lockfile!"
$dotlockfile_command -u "$LOCKFILE"
echo "Unlock lockfile finished!"

echo "Finish Sync Mails!"
