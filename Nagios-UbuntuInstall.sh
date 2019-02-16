#!/bin/bash
################################################################################
# Script for installing Nagios on Ubuntu
# Author: Allwyn Pinto
#-------------------------------------------------------------------------------
# This script will install Nagios 4.4.3 on Ubuntu 18.04. It comes with user
#nagiosadmin and a password of your choice
#-------------------------------------------------------------------------------
# This install is based of Nagios Website 
# 
# download file:
# sudo nano nagios-install.sh
# Place this content in it and then make the file executable:
# sudo chmod +x nagios-install.sh
# Execute the script to install Nagios Core:
# ./nagios-install
################################################################################

exiterr() { echo "Error: $1" >&2; exit 1; }
os_type=$(lsb_release -si 2>/dev/null)

#-------------------------------------------------------------------------------
# Checking OS, doing updates, and installing dependices
#-------------------------------------------------------------------------------

if [ "$os_type" == "Ubuntu" ]
then
        echo "Good! Its Ubuntu!"
        echo "Lets Check the Version..."
        if [ `lsb_release -rs` == "18.04" ]
        then
        echo "Its 18.04! We are in Business!"
	echo "Lets Start by updating"
        sudo apt-get update
        sudo apt-get upgrade
	echo "installing a few required Packages"
        sudo apt-get install -y autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php7.2 libgd-dev
        elif [ `lsb_release -rs` == "16.04" ]
        then
        echo "Its 16.04! We are in Business!"
	echo "Lets Start by updating"
        sudo apt-get update
        sudo apt-get upgrade
	echo "installing a few required Packages"
	sudo apt-get install -y autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php7.0 libgd2-xpm-dev
        elif [ `lsb_release -rs` == "14.04" ]
        then
        echo "Its 14.04! We are in Business!"
	echo "Lets Start by updating"
        sudo apt-get update
        sudo apt-get upgrade
	echo "installing a few required Packages"
        sudo apt-get install -y autoconf gcc libc6 make wget unzip apache2 apache2-utils php5 libgd2-xpm-dev
        else
        exiterr "This script only supports Ubuntu 14.04, 16.04 and 18.04"
        fi
else
        exiterr "This script only supports Ubuntu 14.04, 16.04 and 18.04"
fi

#-------------------------------------------------------------------------------
# Downloading the Source
#-------------------------------------------------------------------------------

echo "Downloading the Source"
sleep 5  # Waits 5 seconds.
cd /tmp
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.3.tar.gz
tar xzf nagioscore.tar.gz

#-------------------------------------------------------------------------------
# Compiling the Code
#-------------------------------------------------------------------------------

echo "Compiling the Code"
sleep 5  # Waits 5 seconds.
cd /tmp/nagioscore-nagios-4.4.3/
sudo ./configure --with-httpd-conf=/etc/apache2/sites-enabled
sudo make all

#-------------------------------------------------------------------------------
# Creating User and Group
#-------------------------------------------------------------------------------

echo "Creating User and Group"
sleep 5  # Waits 5 seconds.
sudo make install-groups-users
sudo usermod -a -G nagios www-data

#-------------------------------------------------------------------------------
# Install Binaries
#-------------------------------------------------------------------------------

echo "Getting ready to Install Binaries"
sleep 5  # Waits 5 seconds.
sudo make install

#-------------------------------------------------------------------------------
# Install Service / Daemon
#-------------------------------------------------------------------------------

echo "Getting ready to Install Service / Daemon"
sleep 5  # Waits 5 seconds.
sudo make install-daemoninit

#-------------------------------------------------------------------------------
# Install Command Mode
#-------------------------------------------------------------------------------

echo "Getting ready to Install Command Mode"
sleep 5  # Waits 5 seconds.
sudo make install-commandmode


#-------------------------------------------------------------------------------
# Install Configuration Files
#-------------------------------------------------------------------------------

echo "Getting ready to Install Configuration Files"
sleep 5  # Waits 5 seconds.
sudo make install-config

#-------------------------------------------------------------------------------
# Install Apache Configuration Files
#-------------------------------------------------------------------------------

echo "Getting ready to Install Apache Configuration Files"
sleep 5  # Waits 5 seconds.
sudo make install-webconf
sudo a2enmod rewrite
sudo a2enmod cgi

#-------------------------------------------------------------------------------
# Configuring Firewall
#-------------------------------------------------------------------------------

echo "Configuring Firewall for Apache"
sleep 5  # Waits 5 seconds.
sudo ufw allow Apache
sudo ufw reload

#-------------------------------------------------------------------------------
# Create nagiosadmin User Account
#-------------------------------------------------------------------------------

echo "Creating nagiosadmin User Account! Get ready to input a password"
sleep 5  # Waits 5 seconds.
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

if [ `lsb_release -rs` == "18.04" ]
then
	sudo systemctl restart apache2.service
	sudo systemctl start nagios.service
elif [ `lsb_release -rs` == "16.04" ]
then
        sudo systemctl restart apache2.service
	sudo systemctl start nagios.service
elif [ `lsb_release -rs` == "14.04" ]
then
        sudo service apache2 restart
	sudo start nagios
fi




