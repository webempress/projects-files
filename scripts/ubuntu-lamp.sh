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
ROOTDBPWD="thppassword"

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
sudo debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password password $ROOTDBPWD"
sudo debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password_again password $ROOTDBPWD"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server mariadb-client

# check MariaDB status and run security script
sudo service mysql status
# sudo mysql_secure_installation

# Install Expect
sudo apt-get -qq install expect > /dev/null

# Build Expect script
tee ~/secure_our_mysql.sh > /dev/null << EOF
spawn $(which mysql_secure_installation)

expect "Enter password for user root:"
send "$ROOTDBPWD\r"

# expect "Press y|Y for Yes, any other key for No:"
# send "y\r"

# expect "Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG:"
# send "2\r"

expect "Change the root password? ((Press y|Y for Yes, any other key for No) :"
send "n\r"

expect "Remove anonymous users? ((Press y|Y for Yes, any other key for No)"
send "y\r"

expect "Disallow root login remotely? ((Press y|Y for Yes, any other key for No)"
send "y\r"

expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
send "y\r"

EOF

# Run Expect script.
# This runs the "mysql_secure_installation" script which removes insecure defaults.
sudo expect ~/secure_our_mysql.sh

# Cleanup
#rm -v ~/secure_our_mysql.sh # Remove the generated Expect script
#sudo apt-get -qq purge expect > /dev/null # Uninstall Expect, commented out in case you need Expect

# install phpmyadmin. for php7 need to add packages
# sudo add-apt-repository ppa:nijel/phpmyadmin
# sudo apt-get update
# sudo apt-get install -y phpmyadmin

# cd /var/www/html
# sudo ln -s /usr/share/phpmyadmin

# add starter files
cd /vagrant/shared-htdocs
sudo -u vagrant wget -q https://raw.githubusercontent.com/webempress/projects-files/master/files/apache-default-index.html
mv apache-default-index.html index.html

sudo wget -q https://raw.githubusercontent.com/webempress/projects-files/master/files/phpinfo.php
