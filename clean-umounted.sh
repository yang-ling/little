#!/usr/bin/env bash

/usr/bin/udevil clean

MOUNT_ROOT=/media

for f in `ls $MOUNT_ROOT`; do
    ls $MOUNT_ROOT/$f
    isValidMount=$?
    [[ $isValidMount -eq 0 ]] || { /usr/bin/udevil umount -l $MOUNT_ROOT/$f; }
done
