#!/usr/bin/env bash

DELETED_TAG_THRESHOLD=7
SPAM_TAG_THRESHOLD=30

export XDG_CONFIG_HOME=$HOME/.config
export NOTMUCH_CONFIG=$XDG_CONFIG_HOME/notmuch/notmuch-config
function delete-mails-with-deleted-tag {
    for oneMail in $(notmuch search --format=text --output=files tag:deleted); do
        mail_age=$(perl -e 'print int -M $ARGV[0]' "$oneMail")
        if [[ "$mail_age" -gt "$DELETED_TAG_THRESHOLD" ]]; then
            echo "$oneMail has deleted tag and its age is $mail_age and threshold is $DELETED_TAG_THRESHOLD days. Delete it!"
            rm -f "$oneMail"
        else
            echo "$oneMail has deleted tag and its age is $mail_age and threshold is $DELETED_TAG_THRESHOLD days. Do nothing"
        fi
    done
}

function delete-mails-with-spam-tag {
    for oneMail in $(notmuch search --format=text --output=files tag:spam); do
        mail_age=$(perl -e 'print int -M $ARGV[0]' "$oneMail")
        if [[ "$mail_age" -gt "$SPAM_TAG_THRESHOLD" ]]; then
            echo "$oneMail has spam tag and its age is $mail_age and threshold is $SPAM_TAG_THRESHOLD days. Delete it!"
            rm -f "$oneMail"
        else
            echo "$oneMail has spam tag and its age is $mail_age and threshold is $SPAM_TAG_THRESHOLD days. Do nothing"
        fi
    done
}

delete-mails-with-deleted-tag
delete-mails-with-spam-tag
notmuch new
