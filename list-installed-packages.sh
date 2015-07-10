#!/usr/bin/env bash

set -x

whatihave-official() {
    pacman -Qeni | awk '/^Name/ { name=$3 } /^Groups/ { if ( $3 != "base" && $3 != "base-devel" ) { print name } }'
}

whatihave-aur() {
    /usr/bin/pacman -Qemq
}

whatihave-official > $1-$(date +'%F').txt
whatihave-aur > $2-$(date +'%F').txt

set +x
