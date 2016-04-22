#!/usr/bin/env bash

set -ex

theUser=$1

cp -f /var/lib/zeronet/users.json /home/$theUser/Dropbox/Work/zeronet/
