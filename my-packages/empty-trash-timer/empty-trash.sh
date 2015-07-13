#!/usr/bin/env bash

set -ex

theUser=$1

set +e
find /home/$theUser/.Trash -mindepth 1 -depth -mtime +7 -delete
result=$?
set -e

if [[ $result -ne 0 ]]; then
    find /home/$theUser/.Trash -mindepth 1 -depth -mtime +7 -exec rm -rf {} \;
fi
