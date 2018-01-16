#!/bin/bash

# 1. verify VirtualBox & VirtualBox guest additions are up to date
# 2. run: vagrant init ubuntu/trusty64
# 3. Update Vagrantfile
#       vb.memory = "2048"
#
#       config.vm.network "private_network", ip: "192.168.58.<n>"
#       config.vm.hostname = "<yoursite>"
#       config.hostsupdater.remove_on_suspend = false
#
#       config.vm.provision "shell", path: "~/projects-files/scripts/ubuntu-lamp.sh"
#
# 4. Verify the shell provisioner file is stored in the
#    location matching path given in Vagrantfile
# 5. First time-install vbguest plugin:
#    vagrant plugin install vagrant-vbguest
# 6. vagrant up
# ====================

# Define the password for root user of DB.
# It will be passed into the interactive script
ROOTDBPWD="<yourpasswordhere>"

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
# installing full php7 failed repeatedly, so installing just a selection
sudo apt-get install -y python-software-properties software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get -y update
# sudo apt-get install -y php7.0-*
sudo apt-get -y install php7.0-fpm php7.0-mysql php7.0-common php7.0-mbstring php7.0-gd php7.0-json php7.0-cli php7.0-curl libapache2-mod-php7.0

# install MariaDB
# input values for interactive variables
sudo debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password password $ROOTDBPWD"
sudo debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password_again password $ROOTDBPWD"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server mariadb-client

# check MariaDB status
# Uncomment the following line if having problems to display status/info
# sudo service mysql status

# Run security script mysql_secure_installation using Expect
# Install Expect
sudo apt-get -qq install expect > /dev/null

# Build Expect script
tee ~/secure_our_mysql.sh > /dev/null << EOF
    spawn $(which mysql_secure_installation)

    expect "Enter password for user root:"
    send "$ROOTDBPWD\r"

    expect "Change the root password? ((Press y|Y for Yes, any other key for No) :"
    send "n\r"

    expect "Remove anonymous users? ((Press y|Y for Yes, any other key for No)"
    send "y\r"

    expect "Disallow root login remotely? ((Press y|Y for Yes, any other key for No)"
    send "y\r"

    expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
    send "y\r"

    expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No)"
    send "y\r"
EOF

# Run the Expect script
# This runs the "mysql_secure_installation" script which removes insecure defaults.
sudo expect ~/secure_our_mysql.sh

# Cleanup
rm -v ~/secure_our_mysql.sh # Remove the generated Expect script
sudo apt-get -qq purge expect > /dev/null # Uninstall Expect, commented out in case you need Expect

# install phpmyadmin. For php7 need to add packages
sudo add-apt-repository ppa:nijel/phpmyadmin
sudo apt-get update

# Set phpmyadmin paramaters for install
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $ROOTDBPWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/setup-password password $ROOTDBPWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $ROOTDBPWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $ROOTDBPWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/password-confirm password $ROOTDBPWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/debconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/db/app-user string phpmyadmin"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-user string phpmyadmin"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/database-type select mysql"

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y phpmyadmin

sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# add starter files
cd /vagrant/shared-htdocs
sudo -u vagrant wget -q https://raw.githubusercontent.com/webempress/projects-files/master/files/apache-default-index.html
mv apache-default-index.html index.html

sudo wget -q https://raw.githubusercontent.com/webempress/projects-files/master/files/phpinfo.php
