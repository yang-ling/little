#!/usr/bin/env bash

set -ex

getfilesize() {
    filesize=$(stat -c%s "${1}")
}

recursive_crop() {
    filename="${1%.*}"
    convert $1 -crop 100%x50% +repage $filename%d.jpg
    rm -f $1
    for part in ${filename}0.jpg ${filename}1.jpg; do
        filesize=0
        getfilesize ${part}
        if [ $filesize -ge 1000000 ]; then
            recursive_crop ${part}
        fi
    done
}

rename_images() {
    i=0
    for file in $(ls *.jpg); do
        newfilename="${1}_${i}.jpg"
        if [ "$file" != "$newfilename" ]; then
            mv $file $newfilename
        fi
        i=$((i+1))
    done
}

mkdir temp

convert $1.jpg -crop 100%x50% +repage temp/$1%d.jpg

pushd temp

for part in ${1}0.jpg ${1}1.jpg; do
    filesize=0
    getfilesize ${part}
    if [ $filesize -ge 1000000 ]; then
        recursive_crop ${part}
    fi
done
rename_images $1
popd
