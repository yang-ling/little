#!/bin/bash

# This is installation script for Ubuntu Server
# Author: YANG Ling (yangling1984@gmail.com)

# Install common packages
# git, zsh, oh-my-zsh
# Configure vim
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
            echo "$n install start..."
            sudo apt-get -y install $n
            echo "$n installed."
        fi
    done
}

function installOhMyZsh()
{
    if [ -d ~/.oh-my-zsh ]; then
        echo "oh-my-zsh already installed."
        echo "Do you want install again? You current installation will be backup. [Y/n]"
        read response
        [[ $response == "n" ]] && return 0
        rm -rf ~/.oh-my-zsh.bak/
        mv ~/.oh-my-zsh ~/.oh-my-zsh.bak
    fi
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
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
}

function backupFile()
{
    if [ -f $1 ]; then
        echo -n "$1 exists. Do you want to backup it and create it again? [y/N]"
        read response
        [[ $response == "y" ]] || return false
        mv -f $1 ${1}.bak
        echo "Backup finished."
        return true
    fi
}

function commonInstall()
{
    echo -e "\n"
    echo "Common packages installation start..."

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

    # === Update System Start ===
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
    # === Update System End ===

    # Installation
    echo "Install git zsh ..."
    installOrUpdateOnePackage git zsh
    echo "Packages installed"

    # Configure vim
    echo "Configure vim start..."
    if [ ! -d  ~/.vim/bundle/neobundle.vim ]; then
        echo "Cloning neobundle.vim..."
        rm -rf ~/.vim/bundle
        mkdir -p ~/.vim/bundle
        git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
        echo "neobundle.vim cloned"
    fi
    if backupFile ~/.vimrc; then
        echo "Downloading vimrc file..."
        wget https://raw.githubusercontent.com/yang-ling/dotfiles/master/vimrc-server -O ~/.vimrc
        echo "vimrc file downloaded."
    fi
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

    if backupFile ~/.zshrc; then
        echo "Downloading .zshrc file"
        wget https://raw.githubusercontent.com/yang-ling/dotfiles/master/zshrc-server -O ~/.zshrc
        echo ".zshrc file downloaded."
    fi

    echo "Downloading custom zsh plugins..."
    [[ ! -d  ~/.oh-my-zsh/custom/plugins ]] && mkdir -p ~/.oh-my-zsh/custom/plugins
    rm -rf ~/.oh-my-zsh/custom/plugins/common-aliases.plugin.zsh
    wget https://raw.githubusercontent.com/yang-ling/dotfiles/master/oh-my-zsh/custom/plugins/common-aliases.plugin.zsh -O ~/.oh-my-zsh/custom/plugins/common-aliases.plugin.zsh
    echo "Custom zsh plugins downloaded."

    echo "Common packages installation finished."
    echo -e "\n"
}

# Check whether commonInstall executed
function isCommonInstalled()
{
    test -f ~/.oh-my-zsh/custom/plugins/common-aliases.plugin.zsh
}

function addJenkinsPPA()
{
    [[ -f /etc/apt/sources.list.d/jenkins.list ]] && return 0
    echo "Adding Jenkins PPA..."
    wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
    sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
    echo "Jenkins PPA added."
}

function configureJenkins()
{
    if ! backupFile jenkins; then
        return 0
    fi
    # Jenkins nginx config file
    echo "Creating jenkins config file..."
    echo -n "Please input your DNS or IP: "
    read response_dns
    sudo tee jenkins > /dev/null << EOF
upstream app_server {
server 127.0.0.1:8080 fail_timeout=0;
}

server {
listen 80;
listen [::]:80 default ipv6only=on;
server_name ${response_dns};

location / {
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_set_header Host \$http_host;
proxy_redirect off;

if (!-f \$request_filename) {
    proxy_pass http://localhost:8080;
    break;
}
    }
}
EOF
    echo "Jenkins config file created"

    echo "Create symbol link: /etc/nginx/sites-available/jenkins => /etc/nginx/sites-enabled/"
    sudo ln -sf /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
    echo "Symbol link created."

    echo "Restart nginx..."
    sudo service nginx restart
    echo "Nginx restarted."
}
# Install jenkins on Ubuntu Server
function jenkinsInstall()
{
    echo -e "\n"
    echo "Jenkins Server installation start..."
    if ! isCommonInstalled; then
        commonInstall
    fi
    addJenkinsPPA
    installOrUpdateOnePackage jenkins nginx maven

    # Configuration
    cd /etc/nginx/sites-available
    sudo rm -f default ../sites-enabled/default
    configureJenkins

    echo "Jenkins Server installation finished."
    echo -e "\n"
}

function ending()
{
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo "Your shell is not zsh."
        echo "You need reboot to make installation take effect."
        echo -n "Reboot now? [y/N]"
        read response
        [[ $response == "y" ]] && sudo shutdown -r 0
    fi
}

usage() {
  echo "$(basename $0) <COMMAND>"
  echo -e "\nCOMMAND:"
  echo -e '\tcommon\t\tInstall common packages: git, zsh and configure vim'
  echo -e '\tjenkins\t\tSet up a jenkins server.'
}

## Main
case $1 in
  'common') commonInstall; ending;;
  'jenkins')    jenkinsInstall; ending;;
  'help' | '--help' | '-h' | '') usage;;
  *)           echo "$(basename $0): unknown option '$@'"; exit 1;;
esac

exit 0
