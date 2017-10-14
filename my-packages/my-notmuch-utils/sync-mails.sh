#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

source /usr/local/lib/my-notmuch-utils/commons.sh

LOCKFILE=/tmp/sync-mails-dotfile

echo "Start Sync Mails!"

echo "Check lockfile $LOCKFILE"
$dotlockfile_command -r 10 -l -p "$LOCKFILE"

[[ $? -ne 0 ]] && { sendWarning "Sync Mail" "Previous sync lasts too long!"; }
echo "Lockfile check OK!"

echo "Start mbsync!"
set +e
$mbsync_command -c ~/.config/isync/mbsyncrc -a
[[ $? -ne 0 ]] && { sendWarning "Sync Mail" "mbsync throws error!"; }
set -e
echo "Finish mbsync!"

echo "Start offlineimap!"
set +e
$offlineimap_command -c ~/.config/offlineimap/offlineimap.conf
set -e
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

echo "Check New Mails"
while read -r -d $'\0' oneFolder
do
    NEW="new"
    if  test "x${oneFolder##*/}" = "x$NEW" ; then
        mailbox="${oneFolder%/new}"
        account="${mailbox%/*}"
        mailbox="${mailbox##*/}"
        account="${account##*/}"
        [[ -n "$(ls $oneFolder)" ]] && \
            $notify_send_command "New Mail(s) in $account/$mailbox " -t 5000
    fi
done < <(find "$MAIL_ROOT" -type d -path "$MAIL_ROOT/.notmuch" -prune -o -type d -print0)

echo "Finish Sync Mails!"
