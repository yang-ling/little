#!/usr/bin/bash

# Git Push Force

function gpf()
{
    declare -a CANNOT_PUSH=("master" "develop")
    current=$(git rev-parse --abbrev-ref HEAD)
    for forbidden in "${CANNOT_PUSH[@]}"
    do
        [[ "$current" == "$forbidden" ]] && { "Cannot push $current !"; exit 1; }
    done
    echo -n "Do you want to force push $current? [yN]: "
    read response
    [[ "$response" == "y" ]] || { "Force push cancelled."; exit 1; }
    git push origin --delete "$current" && git push origin "$current"
}
gpf
