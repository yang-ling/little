#!/usr/bin/env bash

set -x

sendWarnings() {
    notify-send -u critical "$1"
}

systemctl --failed | grep -v grep | grep "0 loaded units listed"
noFailed=$?
if [[ $noFailed -ne 0 ]]; then
    sendWarnings "System wide units failed. Run systemctl --failed to check details."
fi

systemctl --user --failed | grep -v grep | grep "0 loaded units listed"
noFailed=$?
if [[ $noFailed -ne 0 ]]; then
    sendWarnings "User units failed. Run systemctl --user --failed to check details."
fi

set +x
