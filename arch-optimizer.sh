#!/usr/bin/env bash

set -x

isClean=1
orphans() {
    if [[ ! -n $(pacman -Qdt) ]]; then
        echo "No orphans to remove."
        isClean=0
    else
        pacman -Runs --noconfirm $(pacman -Qdtq)
    fi
}

while $isClean -ne 0 ; do
    orphans
done

/usr/bin/paccache -r && /usr/bin/paccache -ruk0 && pacman-optimize && sync

set +x
