#!/usr/bin/env bash

set -ex

emptyFolder() {
    set +e
    find $1 -mindepth 1 -depth -mtime +7 -delete
    result=$?
    set -e
    if [[ $result -ne 0 ]]; then
        find $1 -mindepth 1 -depth -mtime +7 -exec rm -rf {} \;
    fi
}

while IFS='' read -r line ; do
    [[ -z $line ]] && continue
    [[ "$line" =~ ^#.*$ ]] && continue
    emptyFolder $line
done < "$1"
