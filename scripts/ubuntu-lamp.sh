#!/bin/bash

# 1. verify VirtualBox & VirtualBox guest additions are up to date
# 2. run: vagrant init ubuntu/trusty64
# 3. in virtual box increase memory to 2048MB
# 4. install vbguest plugin: vagrant plugin install vagrant-vbguest
# 5. Update vagrantfile
#       config.vm.network "private_network", ip: "192.168.58.N"
#       config.vm.hostname = "www.<yoursite>.dev"   "<yoursite>"
#       config.hostsupdater.remove_on_suspend = false
#
#       vagrant.configure("2") do |config|
#          config.vm.provision "shell", path: "~/projects-files/ubuntu-lamp.sh"
#       end
#

# ssh into box
vagrant ssh

# Check for ubuntu and package updates, install
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade

# Install Apache2
sudo apt-get install apache2 apache2-utils
sudo service apache2 status

# stop apache and remove default root dir
sudo service apache2 stop
sudo rm -rf /var/www/html

# check if shared dir exists, create if it doesn't then symlink to shared directory
sudo mkdir -p /vagrant/shared-htdocs
sudo ln -s /vagrant/shared-htdocs /var/www/html
sudo service apache2 start

# install MariaDB
sudo apt-get install mariadb-server mariadb-client

# check MariaDB status and run security script
sudo service mysql status
sudo mysql_secure_installation

# install php7. 1st update pkgs for php7
sudo apt-get install python-software-properties software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update

sudo apt-get install php7.0-*

# install phpmyadmin. for php7 need to add packages
sudo add-apt-repository ppa:nijel/phpmyadmin
sudo apt-get update
sudo apt-get install phpmyadmin
