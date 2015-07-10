#!/usr/bin/env bash

set -ex

theUser=$1

find /home/$theUser/.Trash -mindepth 1 -depth -mtime +7 -delete
