#!/usr/bin/env bash

set -ex

for aur in $(ls -d *)
do
    [[ -d $aur ]] || { continue; }
    pushd $aur
    makepkg -s -i -r -c -C --needed
    popd
done
