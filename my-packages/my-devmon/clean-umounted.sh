#!/usr/bin/env bash
set -x

/usr/bin/udevil clean

MOUNT_ROOT=/media
cd $MOUNT_ROOT

for f in `ls $MOUNT_ROOT`; do
    /usr/bin/udevil umount -l $MOUNT_ROOT/$f
    if [[ $? -ne 0 ]]; then
        sudo /usr/bin/udevil umount -l $MOUNT_ROOT/$f
    fi
    [[ $? -ne 0 ]] && { echo "Error when unmounting $MOUNT_ROOT/$f"; exit 1; }
done

set +x
