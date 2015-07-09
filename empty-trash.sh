#!/usr/bin/env bash

theUser=$1

find /home/$theUser/.Trash -mindepth 1 -depth -mtime +7 -delete
