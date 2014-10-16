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

function installOrUpdateOnePackage()
{
    for n
    do
        willInstall=true
        if dpkg -s "$n" >/dev/null 2>&1; then
            echo "$n is aready installed."
            echo -n "Do you want to update it? [Y/n]"
            read response2
            if [ "$response2" == "n" ]; then
                willInstall=false
            fi
        fi
        if willInstall; then
            echo "$n update start..."
            sudo apt-get -y install $n
            echo "$n updated."
        fi
    done
}

function backupFile()
{
    if [ -f $1 ]; then
        echo "$1 exists. Backup..."
        mv -f $1 ${1}.bak
        echo "Backup finished."
    fi
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
needUpdate=0
echo "Checking whether git PPA exists..."
if [ ! -f "/etc/apt/sources.list.d/git-core-ppa-trusty.list" ]; then
    echo "Add git PPA..."
    sudo add-apt-repository ppa:git-core/ppa
    echo "git PPA added."
    needUpdate=1
fi
echo "Check finished."

# === PPA Section end ===

if [ $needUpdate -ne 1 ]; then
    echo -n "Do you want to update and upgrade system? [Y/n]"
    read response
    [[ "$response" != "n" ]] && needUpdate=1
fi

if [ $needUpdate -eq 1 ]; then
    echo "Update system..."
    sudo aptitude update -y
    echo "System updated"

    echo "Upgrade system..."
    sudo aptitude upgrade -y
    echo "System upgraded."
fi

# Installation
echo "Install git zsh ..."
installOrUpdateOnePackage git zsh
echo "Packages installed"

# Config vim
echo "Configure vim start..."
if [ ! -d  ~/.vim/bundle/neobundle.vim ]; then
    echo "Cloning neobundle.vim..."
    rm -rf ~/.vim/bundle
    mkdir -p ~/.vim/bundle
    git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
    echo "neobundle.vim cloned"
fi
backupFile ~/.vimrc
echo "Downloading vimrc file..."
wget https://raw.githubusercontent.com/yang-ling/dotfiles/master/vimrc-server -O ~/.vimrc
echo "vimrc file downloaded."
echo "Configure vim finished."

# Config zsh and oh-my-zsh
# Ignore errors
installOhMyZsh || true
if [ ! -d ~/.oh-my-zsh ]; then
    echo "oh-my-zsh install failed."
    echo "You need run this script again"
    exit 1
fi
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "\033[0;34mTime to change your default shell to zsh!\033[0m"
    chsh -s `which zsh`
fi

backupFile ~/.zshrc
wget https://raw.githubusercontent.com/yang-ling/dotfiles/master/zshrc-server -O ~/.zshrc
mkdir -p ~/.oh-my-zsh/custom/plugins
wget https://raw.githubusercontent.com/yang-ling/dotfiles/master/oh-my-zsh/custom/plugins/common-aliases.plugin.zsh -O ~/.oh-my-zsh/custom/plugins/common-aliases.plugin.zsh

sudo shutdown -r 0
exit 0
