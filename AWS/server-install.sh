#!/bin/bash

# This is installation script for Ubuntu Server
# Author: YANG Ling (yangling1984@gmail.com)

# Install common packages
# git, zsh, oh-my-zsh
# Configure vim
_OH_MY_ZSH=~/.oh-my-zsh
_OH_MY_ZSH_CUSTOM_PLUGINS=${_OH_MY_ZSH}/custom/plugins
_ZSHRC=~/.zshrc
_VIMRC=~/.vimrc
_VIM=~/.vim
_VIM_BUNDLE=${_VIM}/bundle
_NEOBUNDLE=${_VIM_BUNDLE}/neobundle.vim

_NEOBUNDLE_REPO=git://github.com/Shougo/neobundle.vim
_VIMRC_SERVER_URL=https://raw.githubusercontent.com/yang-ling/dotfiles/master/vimrc-server
_ZSHRC_SERVER_URL=https://raw.githubusercontent.com/yang-ling/dotfiles/master/zshrc-server
_OH_MY_ZSH_INSTALL_URL=https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh
_OH_MY_ZSH_CUSTOM_PLUGINS_URL_BASE=https://raw.githubusercontent.com/yang-ling/dotfiles/master/oh-my-zsh/custom/plugins

function echoHeader()
{
    # Blue, underline
    echo -e "\033[0;34;4m${1}\033[0m"
}
function echoSection()
{
    echo -e "\033[47;30m${1}\033[0m"
}
function echoInfo()
{
    # Green
    echo -e "\033[0;32m${1}\033[0m"
}
function echoError()
{
    # Red
    echo -e "\033[0;31m${1}\033[0m"
}

function installOrUpdateOnePackage()
{
    for n
    do
        willInstall=true
        if dpkg -s "$n" >/dev/null 2>&1; then
            echo -n "$n is aready installed. Do you want to update $n? [y/N]"
            read response2
            if [ "$response2" != "y" ]; then
                willInstall=false
            fi
        fi
        if $willInstall; then
            echoInfo "$n install start..."
            sudo apt-get -y install $n
            echoInfo "$n installed."
        fi
    done
}

function installOhMyZsh()
{
    if [ -d $_OH_MY_ZSH ]; then
        echo -n "oh-my-zsh already installed. Do you want install again? You current installation will be backup. [y/N]"
        read response
        [[ $response == "y" ]] || return 0
        rm -rf ${_OH_MY_ZSH}.bak
        mv ${_OH_MY_ZSH} ${_OH_MY_ZSH}.bak
    fi
    echo -n "You must know your password. Do you have it? [yes/no]"
    read response
    if [ "$response" != "yes" ]; then
        echo -n "Are you on EC2 and your username is ubuntu? [yes/no]"
        read response2
        if [ "$response2" == "yes" ]; then
            sudo passwd ubuntu
        else
            echoInfo "Please get your password"
            exit 1
        fi
    fi
    wget $_OH_MY_ZSH_INSTALL_URL -O - | zsh
}

function backupFile()
{
    if [ -f $1 ]; then
        echo -n "$1 exists. Do you want to backup it and create it again? [y/N]"
        read response
        [[ "$response" == "y" ]] || return 1
        mv -f $1 ${1}.bak
        echoInfo "Backup finished."
    fi
    return 0
}

function downloadCustomZshPlugin()
{
    for n
    do
        if backupFile ${_OH_MY_ZSH_CUSTOM_PLUGINS}/$n; then
            wget ${_OH_MY_ZSH_CUSTOM_PLUGINS_URL_BASE}/$n -O ${_OH_MY_ZSH_CUSTOM_PLUGINS}/$n
        fi
    done
}

function commonInstall()
{
    echo -e "\n"
    echoHeader "Common packages installation start..."

    # === PPA Section Start ===
    # Add PPA for git
    needUpdate=0
    echoSection "Checking whether git PPA exists..."
    if [ ! -f "/etc/apt/sources.list.d/git-core-ppa-trusty.list" ]; then
        echoInfo "Add git PPA..."
        sudo add-apt-repository ppa:git-core/ppa
        echoInfo "git PPA added."
        needUpdate=1
    fi
    echoSection "Check finished."
    # === PPA Section end ===

    # === Update System Start ===
    echoSection "Update System Start..."
    if [ $needUpdate -ne 1 ]; then
        echo -n "Do you want to update and upgrade system? [y/N]"
        read response
        [[ "$response" == "y" ]] && needUpdate=1
    fi

    if [ $needUpdate -eq 1 ]; then
        echoInfo "Update system..."
        sudo aptitude update -y
        echoInfo "System updated"

        echoInfo "Upgrade system..."
        sudo aptitude upgrade -y
        echoInfo "System upgraded."
    fi
    echoSection "Update System Finished."
    # === Update System End ===

    # Installation
    echoSection "Install git zsh ..."
    installOrUpdateOnePackage git zsh
    echoSection "Packages installed"

    # Configure vim
    echoSection "Configure vim start..."
    if [ ! -d $_NEOBUNDLE ]; then
        echoInfo "Cloning neobundle.vim..."
        rm -rf $_VIM_BUNDLE
        mkdir -p $_VIM_BUNDLE
        git clone $_NEOBUNDLE_REPO $_NEOBUNDLE
        echoInfo "neobundle.vim cloned"
    fi
    if backupFile $_VIMRC; then
        echoInfo "Downloading vimrc file..."
        wget $_VIMRC_SERVER_URL -O $_VIMRC
        echoInfo "vimrc file downloaded."
    fi
    echoSection "Configure vim finished."

    # Config zsh and oh-my-zsh
    echoSection "Configure zsh start..."
    # Ignore errors
    installOhMyZsh || true
    if [ ! -d $_OH_MY_ZSH ]; then
        echoError "oh-my-zsh install failed."
        echoError "You need run this script again"
        exit 1
    fi
    if [ "$SHELL" != "$(which zsh)" ]; then
        echoInfo  "Time to change your default shell to zsh!"
        chsh -s `which zsh`
    fi

    if backupFile $_ZSHRC; then
        echoInfo "Downloading .zshrc file"
        wget $_ZSHRC_SERVER_URL -O $_ZSHRC
        echoInfo ".zshrc file downloaded."
    fi

    echoInfo "Downloading custom zsh plugins..."
    [[ ! -d $_OH_MY_ZSH_CUSTOM_PLUGINS ]] && mkdir -p $_OH_MY_ZSH_CUSTOM_PLUGINS
    downloadCustomZshPlugin common-aliases.plugin.zsh
    echoInfo "Custom zsh plugins downloaded."
    echoSection "Zsh configuration finished."

    echoHeader "Common packages installation finished."
    echo -e "\n"
}

# Check whether commonInstall executed
function isCommonInstalled()
{
    test -f ${_OH_MY_ZSH_CUSTOM_PLUGINS}/common-aliases.plugin.zsh
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
    if ! backupFile /etc/nginx/sites-available/jenkins; then
        return 0
    fi
    # Jenkins nginx config file
    echo "Creating jenkins config file..."
    echo -n "Please input your DNS or IP: "
    read response_dns
    sudo tee /etc/nginx/sites-available/jenkins > /dev/null << EOF
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
