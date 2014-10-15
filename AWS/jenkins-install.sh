#!/bin/bash

# Install jenkins on Ubuntu Server
# Please run common-init.sh first

# Check whether common-init.sh has executed.
echo "Checking whether common-init.sh executed..."
if [ ! -d ~/.vim/bundle/neobundle.vim ]; then
    echo "It seems you haven't executed common-init.sh"
    if [ -f ./common-init.sh ]; then
        echo -n "common-init.sh is found. Do you want to execute it? [Y/n]"
        read response
        if [ "$response" != "n" ]; then
            bash common-init.sh
            exit 0
        fi
    else
        echo "And common-init.sh is not in the same folder"
        echo "It is recommended to run common-init.sh first"
        echo -n "Do you still want to continue?[y/N]"
        read response2
        [[ "$response2" == "y" ]] || exit 1
    fi
else
    echo "Check OK."
fi

echo "Check whether jenkins installed..."
if dpkg -s "jenkins" >/dev/null 2>&1; then
    echo "Jenkins is already installed."
    echo -n "Do you want to update it? [Y/n]"
    read response2
    if [ "$response2" != "n" ]; then
        echo "Jenkins update start..."
        sudo apt-get update
        sudo apt-get -y install jenkins
        echo "Jenkins updated."
    fi
else
    echo "Install jenkins..."
    wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
    sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
    sudo apt-get update
    sudo apt-get -y install jenkins
    echo "Jenkins installed."
fi

# Install nginx
echo "Install Nginx..."
sudo aptitude -y install nginx
echo "Nginx installed."

cd /etc/nginx/sites-available
sudo rm -f default ../sites-enabled/default
if [ -f "jenkins" ]; then
    echo "jenkins config file aready exists!"
    echo "Make backup: jenkins.bak"
    sudo mv jenkins jenkins.bak
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
