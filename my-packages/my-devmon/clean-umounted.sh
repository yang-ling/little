#!/usr/bin/env bash
set -x

/usr/bin/udevil clean

MOUNT_ROOT=/media
cd $MOUNT_ROOT

for f in `ls $MOUNT_ROOT`; do
    /usr/bin/udevil umount -l $MOUNT_ROOT/$f
done

set +x
