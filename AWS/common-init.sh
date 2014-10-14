#!/bin/bash

# A script to init a server
# For Ubuntu Server
# Usage: ssh to the server and execute this command

set -e -x

# Wrap this in a function
# because if directly call this install.sh it will ask for password
# But the prompt disappear very quickly and if you don't input password
# The whole script will be breaked.
# So I wrap it here to omit the error.
function installOhMyZsh()
{
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
}

echo -n "You must know your password. Do you have it? [yes/no]"
read response
if [ "$response" != "yes" ]; then
    echo -n "Are you on EC2 and your username is ubuntu? [yes/no]"
    read response2
    if [ "$response2" == "yes" ]; then
        sudo passwd ubuntu
    else
        echo "Please get your password"
        exit 1
    fi
fi

# === PPA Section Start ===

# Add PPA for git
if [ ! -f "/etc/apt/sources.list.d/git-core-ppa-trusty.list" ]; then
    sudo add-apt-repository ppa:git-core/ppa
fi

# === PPA Section end ===

sudo aptitude update -y
sudo aptitude upgrade -y

# Installation
sudo aptitude install -y git zsh

# Config vim
rm -rf ~/.vim/bundle
mkdir -p ~/.vim/bundle
git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
wget https://raw.githubusercontent.com/yang-ling/dotfiles/master/vimrc-server -O ~/.vimrc

# Config zsh and oh-my-zsh
installOhMyZsh
chsh -s `which zsh`
wget https://raw.githubusercontent.com/yang-ling/dotfiles/master/zshrc-server -O ~/.zshrc
mkdir -p ~/.oh-my-zsh/custom/plugins
wget https://raw.githubusercontent.com/yang-ling/dotfiles/master/oh-my-zsh/custom/plugins/common-aliases.plugin.zsh -O ~/.oh-my-zsh/custom/plugins/common-aliases.plugin.zsh

sudo shutdown -r 0

