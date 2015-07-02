#!/usr/bin/env bash
set -x

/usr/bin/udevil clean

MOUNT_ROOT=/media
cd $MOUNT_ROOT

for f in `ls $MOUNT_ROOT`; do
    ls $MOUNT_ROOT/$f
    isValidMount=$?
    if [[ $isValidMount -eq 0 ]]; then
        # Delete this directory if it is empty
        /usr/bin/rmdir $f
    else
        # Cannot access it. Try to umount it by lazy umount
        /usr/bin/udevil umount -l $MOUNT_ROOT/$f
    fi
done

set +x
