#!/usr/bin/env bash

set -ex

emptyFolder() {
    find $1 -mindepth 1 -depth -mtime +7 -delete
}

while IFS='' read -r line ; do
    [[ -z $line ]] && continue
    [[ "$line" =~ ^#.*$ ]] && continue
    emptyFolder $line
done < "$1"
