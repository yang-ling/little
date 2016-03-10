#!/usr/bin/env bash

set -ex

images_flag=0

has_images_folder() {
    images_flag=0
    for folder in $(ls .); do
        if [ -d $folder ] && [ "$folder" == "images" ]; then
            images_flag=1
        fi
    done
}

exec_image() {
    has_images_folder
    if [ $images_flag -eq 1 ]; then
        ymake_main.sh
    else
        for folder in $(ls .); do
            if [ -d $folder ]; then
                pushd $folder
                exec_image
                popd
            fi
        done
    fi
}

exec_image
