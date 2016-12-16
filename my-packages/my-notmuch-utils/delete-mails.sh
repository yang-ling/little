#!/usr/bin/env bash

DELETED_TAG_THRESHOLD=7
SPAM_TAG_THRESHOLD=30

source /usr/local/lib/my-notmuch-utils/commons.sh

function delete-mails-with-deleted-tag {
    for oneMail in $($notmuch_command search --format=text --output=files tag:deleted); do
        mail_age=$($perl_command -e 'print int -M $ARGV[0]' "$oneMail")
        if [[ "$mail_age" -gt "$DELETED_TAG_THRESHOLD" ]]; then
            echo "$oneMail has deleted tag and its age is $mail_age and threshold is $DELETED_TAG_THRESHOLD days. Delete it!"
            rm -f "$oneMail"
        else
            echo "$oneMail has deleted tag and its age is $mail_age and threshold is $DELETED_TAG_THRESHOLD days. Do nothing"
        fi
    done
}

function delete-mails-with-spam-tag {
    for oneMail in $($notmuch_command search --format=text --output=files tag:spam); do
        mail_age=$($perl_command -e 'print int -M $ARGV[0]' "$oneMail")
        if [[ "$mail_age" -gt "$SPAM_TAG_THRESHOLD" ]]; then
            echo "$oneMail has spam tag and its age is $mail_age and threshold is $SPAM_TAG_THRESHOLD days. Delete it!"
            rm -f "$oneMail"
        else
            echo "$oneMail has spam tag and its age is $mail_age and threshold is $SPAM_TAG_THRESHOLD days. Do nothing"
        fi
    done
}

lock_notmuch 30
[[ $? -eq 0 ]] || { exit 1; }

delete-mails-with-deleted-tag
delete-mails-with-spam-tag
$notmuch_command new

unlock_notmuch
