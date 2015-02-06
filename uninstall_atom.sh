#!/bin/bash

# This script is used to remove all installation files of atom,
# which is build and installed from git source code

sudo rm -v /usr/local/bin/atom

rm -rf ~/.atom
rm -rf ~/.config/Atom-Shell

rm -v ~/.local/share/applications/atom.desktop
sudo rm -v /usr/local/bin/apm

sudo rm -rf /usr/local/share/atom/

sudo rm -v /usr/local/share/applications/Atom.desktop
