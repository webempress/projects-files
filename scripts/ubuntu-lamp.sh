#!/bin/bash

# 1. verify VirtualBox & VirtualBox guest additions are up to date
# 2. run: vagrant init ubuntu/trusty64
# 5. Update vagrantfile
#       vb.memory = "2048"
#
#       config.vm.network "private_network", ip: "192.168.58.N"
#       config.vm.hostname = "www.<yoursite>.dev"   "<yoursite>"
#       config.hostsupdater.remove_on_suspend = false
#
#       config.vm.provision "shell", path: "~/projects-files/scripts/ubuntu-lamp.sh"
#
# 4. First time-install vbguest plugin: vagrant plugin install vagrant-vbguest
# 3. vagrant up

# try to give mariadb the password so it doesn't kill the automated install
ROOTDBPWD="password"

# Check for ubuntu and package updates, install
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade

# Install Apache2
sudo apt-get install -y apache2 apache2-utils
sudo service apache2 status

# stop apache and remove default root dir
sudo service apache2 stop
sudo rm -rf /var/www/html

# check if shared dir exists, create if it doesn't then symlink to shared directory
sudo mkdir -p /vagrant/shared-htdocs
sudo ln -s /vagrant/shared-htdocs /var/www/html
sudo service apache2 start

# install php7. 1st update pkgs for php7
sudo apt-get install -y python-software-properties software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get -y update
# sudo apt-get install -y php7.0-*
sudo apt-get -y install php7.0-fpm php7.0-mysql php7.0-common php7.0-mbstring php7.0-gd php7.0-json php7.0-cli php7.0-curl libapache2-mod-php7.0

# install MariaDB
sudo debconf-set-selections <<< "mariadb-server-5.5 mariadb-server/root_password password $ROOTDBPWD"
sudo debconf-set-selections <<< "mariadb-server-5.5 mariadb-server/root_password_again password $ROOTDBPWD"

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server mariadb-client

# check MariaDB status and run security script
sudo service mysql status

# install phpmyadmin. for php7 need to add packages
sudo add-apt-repository ppa:nijel/phpmyadmin
sudo apt-get update
sudo apt-get install -y phpmyadmin

cd /var/www/html
sudo ln -s /usr/share/phpmyadmin

# add starter files
cd /vagrant/shared-htdocs
sudo -u vagrant wget -q https://raw.githubusercontent.com/webempress/projects-files/master/files/apache-default-index.html
mv apache-default-index.html index.html

# using global so can skip this file
# sudo wget -q https://raw.githubusercontent.com/webempress/projects-files/master/files/git-ignore
# mv git-ignore /vagrant/.gitignore

sudo wget -q https://raw.githubusercontent.com/webempress/projects-files/master/files/phpinfo.php
