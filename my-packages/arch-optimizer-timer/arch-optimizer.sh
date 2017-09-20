#!/usr/bin/env bash

set -ex

isClean=1
orphans() {
    if [[ ! -n $(pacman -Qdt) ]]; then
        echo "No orphans to remove."
        isClean=0
    else
        pacman -Runs --noconfirm $(pacman -Qdtq)
    fi
}

while [ $isClean -ne 0 ] ; do
    orphans
done

# Keep one generation for each package and remove all uninstalled package cache.
/usr/bin/paccache -rk1 -v && /usr/bin/paccache -ruk0 -v && pacman-optimize && sync
