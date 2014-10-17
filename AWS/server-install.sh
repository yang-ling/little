#!/bin/bash

# This is installation script for Ubuntu Server
# Author: YANG Ling (yangling1984@gmail.com)

# Install common packages
# git, zsh, oh-my-zsh
# Configure vim
set -e

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

function updateSystem()
{
    echoInfo "Update system..."
    sudo aptitude update -y
    echoInfo "System updated"
}

function installOrUpdateOnePackage()
{
    for n
    do
        echoInfo "$n install start..."
        sudo apt-get -y install $n
        echoInfo "$n installed."
    done
}

function installOhMyZsh()
{
    backupFileOrFolder $_OH_MY_ZSH

    if [ "$SHELL" != "$(which zsh)" ]; then
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
    fi
    wget $_OH_MY_ZSH_INSTALL_URL -O - | zsh
}

function backupFileOrFolder()
{
    if [ -f $1 ] || [ -d $1 ]; then
        rm -rf ${1}.bak
        mv -f $1 ${1}.bak
        echoInfo "$1 exists. Backup to ${1}.bak"
    fi
}

function downloadCustomZshPlugin()
{
    for n
    do
        wget ${_OH_MY_ZSH_CUSTOM_PLUGINS_URL_BASE}/$n -O ${_OH_MY_ZSH_CUSTOM_PLUGINS}/$n
    done
}

function commonInstall()
{
    echo -e "\n"
    echoHeader "Common packages installation start..."

    # === PPA Section Start ===
    # Add PPA for git
    firstRun=false
    echoSection "Checking whether git PPA exists..."
    if [ ! -f "/etc/apt/sources.list.d/git-core-ppa-trusty.list" ]; then
        echoInfo "Add git PPA..."
        sudo add-apt-repository ppa:git-core/ppa
        echoInfo "git PPA added."
        # PPA will be added at first run
        firstRun=true
    fi
    echoSection "Check finished."
    # === PPA Section end ===

    # === Update System Start ===
    echoSection "Update System Start..."

    updateSystem

    if $firstRun; then
        # Only upgrade system at first run
        # Because upgrading system too often may cause problems.
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
    backupFileOrFolder $_VIMRC
    echoInfo "Downloading vimrc file..."
    wget $_VIMRC_SERVER_URL -O $_VIMRC
    echoInfo "vimrc file downloaded."
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

    backupFileOrFolder $_ZSHRC
    echoInfo "Downloading .zshrc file"
    wget $_ZSHRC_SERVER_URL -O $_ZSHRC
    echoInfo ".zshrc file downloaded."

    echoInfo "Configure custom zsh plugins..."
    [[ ! -d $_OH_MY_ZSH_CUSTOM_PLUGINS ]] && mkdir -p $_OH_MY_ZSH_CUSTOM_PLUGINS
    downloadCustomZshPlugin common-aliases.plugin.zsh
    echoInfo "Custom zsh plugins configuration finished."
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
    echoSection "Adding Jenkins PPA..."
    wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
    sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
    echoSection "Jenkins PPA added."
    updateSystem
}

function configureJenkins()
{
    if [ -f /etc/nginx/sites-available/jenkins ]; then
        echo -n "Jenkins configuration file exists. Do you want to reset it? [y/N]"
        read response
        [[ "$response" == "y" ]] || return 0
    fi
    backupFileOrFolder /etc/nginx/sites-available/jenkins
    # Jenkins nginx config file
    echoInfo "Creating jenkins config file..."
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
    echoInfo "Jenkins config file created"

    echoInfo "Create symbol link: /etc/nginx/sites-available/jenkins => /etc/nginx/sites-enabled/"
    sudo ln -sf /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
    echoInfo "Symbol link created."

    echoInfo "Restart nginx..."
    sudo service nginx restart
    echoInfo "Nginx restarted."
}
# Install jenkins on Ubuntu Server
function jenkinsInstall()
{
    echo -e "\n"
    echoHeader "Jenkins Server installation start..."
    if ! isCommonInstalled; then
        commonInstall
    fi
    addJenkinsPPA
    installOrUpdateOnePackage jenkins nginx maven

    # Configuration
    cd /etc/nginx/sites-available
    sudo rm -f default ../sites-enabled/default
    configureJenkins

    echoHeader "Jenkins Server installation finished."
    echo -e "\n"
}

function ending()
{
    if [ "$SHELL" != "$(which zsh)" ]; then
        echoInfo "Your shell is not zsh."
        echoInfo "You need reboot to make installation take effect."
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
