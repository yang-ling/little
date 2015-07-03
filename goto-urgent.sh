#!/usr/bin/env bash

i3-msg -t get_workspaces | grep "\"urgent\":true"
hasUrgent=$?
if [[ $hasUrgent -eq 0 ]]; then
    i3-msg -t command "[urgent=latest] focus"
else
    i3-msg -t command "workspace back_and_forth"
fi
