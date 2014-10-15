#!/bin/bash

# A script to init a server
# For Ubuntu Server
# Usage: ssh to the server and execute this command

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
echo "Checking whether git PPA exists..."
if [ ! -f "/etc/apt/sources.list.d/git-core-ppa-trusty.list" ]; then
    echo "Add git PPA..."
    sudo add-apt-repository ppa:git-core/ppa
    echo "git PPA added."
fi
echo "Check finished."

# === PPA Section end ===

echo "Update system..."
sudo aptitude update -y
echo "System updated"

echo "Upgrade system..."
sudo aptitude upgrade -y
echo "System upgraded."

# Installation
echo "Install git zsh ..."
sudo aptitude install -y git zsh
echo "Packages installed"

# Config vim
rm -rf ~/.vim/bundle
mkdir -p ~/.vim/bundle
git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
wget https://raw.githubusercontent.com/yang-ling/dotfiles/master/vimrc-server -O ~/.vimrc

# Config zsh and oh-my-zsh
# Ignore errors
installOhMyZsh || true
if [ ! -d ~/.oh-my-zsh ]; then
    echo "oh-my-zsh install failed."
    echo "You need run this script again"
    exit 1
fi
chsh -s `which zsh`
wget https://raw.githubusercontent.com/yang-ling/dotfiles/master/zshrc-server -O ~/.zshrc
mkdir -p ~/.oh-my-zsh/custom/plugins
wget https://raw.githubusercontent.com/yang-ling/dotfiles/master/oh-my-zsh/custom/plugins/common-aliases.plugin.zsh -O ~/.oh-my-zsh/custom/plugins/common-aliases.plugin.zsh

sudo shutdown -r 0
exit 0
