#!/usr/bin/env bash

function echoHeader {
    # Blue, underline
    echo -e "\033[0;34;4m${1}\033[0m"
}
function echoSection {
    echo -e "\033[47;30m${1}\033[0m"
}
function echoInfo {
    # Green
    echo -e "\033[0;32m${1}\033[0m"
}
function echoError {
    # Red
    echo -e "\033[0;31m${1}\033[0m"
}

# if not sudo, then exec again with sudo
(( EUID != 0 )) && exec sudo -- "$0" "$@"

PACMANNEW="/etc/pacman.d/mirrorlist.pacnew"

if [[ -f "$PACMANNEW" ]]; then
    echoInfo "Found $PACMANNEW. Remove it..."
    rm -f "$PACMANNEW"
    echoInfo "$PACMANNEW is removed."
fi

echoInfo "Backup old mirrorlist file..."
mv -v -f /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist_bak
echoInfo "Backup finished."

echoInfo "Start generating new mirror list..."
reflector --sort score --verbose -c CN -f 5 -l 5 --save /etc/pacman.d/mirrorlist

if [[ $? -ne 0 ]]; then
    echoError "Updating mirror list failed. Rollback previous mirror list file"
    mv -v -f /etc/pacman.d/mirrorlist_bak /etc/pacman.d/mirrorlist
else
    echoInfo "New mirror list file is generated."
    echoSection "Please do sudo pacman -Syyu NOW!"
fi
