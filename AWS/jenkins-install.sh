#!/bin/bash

# Install jenkins on Ubuntu Server
# Please run common-init.sh first

set -e -x

# Check whether common-init.sh has executed.
if [ ! -f ~/.vim/bundle/neobundle.vim ]; then
    echo "It seems you haven't executed common-init.sh"
    if [ -f ./common-init.sh ]; then
        echo -n "common-init.sh is found. Do you want to execute it? [Y/n]"
        read response
        if [ "$response" != "n" ]; then
            bash common-init.sh
        fi
    else
        echo "And common-init.sh is not in the same folder"
        echo "It is recommended to run common-init.sh first"
        echo -n "Do you still want to continue?[y/N]"
        read response2
        [[ "$response2" == "y" ]] || exit 1
    fi
fi
