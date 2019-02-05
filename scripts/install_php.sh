#!/bin/bash -e

echo
echo "Installing php"
echo

# INSTALL PHP5.5
#	sudo apt install -y libapache2-mod-php5 php5 php5-cli php5-common php5-curl php5-dev php5-imagick php5-mcrypt php5-memcached php5-mysqlnd php5-xmlrpc memcached
# For coming Ubuntu 16.04 install (when Memcached issues have been resolved)
#sudo add-apt-repository -y ppa:ondrej/php
#sudo apt update -y
#	sudo apt install pkg-config build-essential libmemcached-dev

# INSTALL PHP5.6
# sudo apt install -y libapache2-mod-php php5.6 php5.6-cli php5.6-common php5.6-curl php5.6-dev php-imagick php5.6-mcrypt php5.6-mbstring php5.6-zip php-memcached php5.6-mysql php5.6-xmlrpc memcached

#sudo apt install -y php-redis php-imagick php-igbinary php-msgpack 
# php-memcached memcached
# INSTALL PHP7.1
#sudo apt install -y --allow-unauthenticated libapache2-mod-php php7.1 php7.1-cli php7.1-common php7.1-curl php7.1-dev php-imagick php-igbinary php-msgpack php7.1-mcrypt php7.1-mbstring php7.1-zip php-memcached php7.1-mysql php7.1-xmlrpc memcached
#sudo apt install libapache2-mod-php php7.1 php7.1-cli php7.1-common php7.1-curl php7.1-dev php-imagick php-igbinary php-msgpack php7.1-mcrypt php7.1-mbstring php7.1-zip php-memcached php7.1-mysql php7.1-xmlrpc memcached

# INSTALL PHP7.2
sudo apt install -y libapache2-mod-php php7.2 php7.2-cli php7.2-common php7.2-curl php7.2-dev php7.2-mbstring php7.2-zip php7.2-mysql php7.2-xmlrpc
sudo apt install -y php-redis php-imagick php-igbinary php-msgpack 
echo



echo 
echo "Configuring php"
echo
# UPDATE PHP CONF
# PHP 5
#cat /srv/tools/conf-client/php-apache2.ini > /etc/php5/apache2/php.ini
#cat /srv/tools/conf-client/php-cli.ini > /etc/php5/cli/php.ini

# PHP 7.1
#cat /srv/tools/conf-client/php-apache2.ini > /etc/php/7.1/apache2/php.ini
#cat /srv/tools/conf-client/php-cli.ini > /etc/php/7.1/cli/php.ini

# PHP 7.2
cat /srv/tools/conf-client/php-apache2.ini > /etc/php/7.2/apache2/php.ini
cat /srv/tools/conf-client/php-cli.ini > /etc/php/7.2/cli/php.ini
echo

echo
echo "Installing and configuring php done"
echo