#!/bin/bash -e

outputHandler "section" "SET UP APACHE/PHP/MARIADB"

if test "$install_webserver_conf" = "Y"; then

	outputHandler "comment" "Configuring Apache and PHP"


	install_apache_servername=$(grep -E "^ServerName" /etc/apache2/apache2.conf || echo "")
	if [ -z "$install_apache_servername" ]; then

		# SET SERVERNAME
		echo "ServerName $HOSTNAME" >> /etc/apache2/apache2.conf
		echo "" >> /etc/apache2/apache2.conf

	else

		sed -i "s/^ServerName\ [a-zA-Z0-9\.\_-]\+/ServerName\ $HOSTNAME/;" /etc/apache2/apache2.conf

	fi

	# remove path (slashes) from output to avoid problem with testing string
	install_parentnode_includes=$(grep "^IncludeOptional \/srv\/conf\/\*\.conf" /etc/apache2/apache2.conf | sed "s/\/srv\/conf\/\*\.conf//;" || echo "")
	if test -z "$install_parentnode_includes"; then

		# ADD GIT CONF SETUP
		echo "IncludeOptional /srv/conf/*.conf" >> /etc/apache2/apache2.conf
		echo "" >> /etc/apache2/apache2.conf

	fi


	# ADD DEFAULT APACHE CONF
	cat /srv/tools/conf-server/default.conf > /etc/apache2/sites-available/default.conf
	# REPLACE EMAIL WITH PREVIOUSLY STATED EMAIL
	outputHandler "comment" "replace default mail with mail you entered earlier"
	# REPLACE EMAIL WITH PREVIOUSLY STATED EMAIL
    grep_apache_email=$(trimString "$(grep "ServerAdmin" /etc/apache2/sites-available/default.conf)")
    is_there_apache_email=$(echo "$grep_apache_email" | cut -d' ' -f2)
    if [ -z "$is_there_apache_email" ]; then
        sed -i "s/ServerAdmin\ /ServerAdmin $install_email/" /etc/apache2/sites-available/default.conf

    fi
    if [ "$is_there_apache_email" = "webmaster@localhost" ]; then
        sed -i "s/webmaster@localhost/$install_email/" /etc/apache2/sites-available/default.conf
    fi	

	# ADD APACHE MODULES
	outputHandler "comment" "enable SSL"
	a2enmod ssl
	outputHandler "comment" "enable rewrite"
	a2enmod rewrite
	outputHandler "comment" "enable headers"
	a2enmod headers

	# ENABLE DEFAULT SITE
	outputHandler "comment" "enable default site"
    a2ensite default

	# DISABLE ORG DEFAULT SITE
	outputHandler "comment" "disable original default site"
    a2dissite 000-default

	# UPDATE PHP CONF
	# PHP 5
	#cat /srv/tools/conf-server/php-apache2.ini > /etc/php5/apache2/php.ini
	#cat /srv/tools/conf-server/php-cli.ini > /etc/php5/cli/php.ini

	# PHP 7.0

	#cat /srv/tools/conf-server/php-apache2.ini > /etc/php/7.0/apache2/php.ini
	#cat /srv/tools/conf-server/php-cli.ini > /etc/php/7.0/cli/php.ini

	# PHP 7.1
	#cat /srv/tools/conf-server/php-apache2.ini > /etc/php/7.1/apache2/php.ini
	#cat /srv/tools/conf-server/php-cli.ini > /etc/php/7.1/cli/php.ini
	#outputHandler "comment" "setting up apache2.ini"
    # PHP 7.2
    #cat /srv/tools/conf-server/php-apache2.ini > /etc/php/7.2/apache2/php.ini

    #outputHandler "comment" "setting up php-cli.ini"
    #cat /srv/tools/conf-server/php-cli.ini > /etc/php/7.2/cli/php.ini

 	# PHP 7.4
    cat /srv/tools/conf-server/php-apache2.ini > /etc/php/7.4/apache2/php.ini

    outputHandler "comment" "setting up php-cli.ini"
    cat /srv/tools/conf-server/php-cli.ini > /etc/php/7.4/cli/php.ini

	outputHandler "comment" "Restarting Apache"
	# RESTART APACHE
	service apache2 restart

	## Do we have root password
	#if [ -n "$db_root_password" ]; then
#
	#	# Checking mysql login - trying to log in without password (UBUNTU 16.04)
	#	dbstatus=$(sudo mysql --user=root -e exit 2>/dev/null || echo 1)
#
	#	# Checking mysql login - trying to log in with temp password (UBUNTU 14.04)
	#	#dbstatus=$(sudo mysql --user=root --password=temp -e exit 2>/dev/null || echo 1)
#
	#	# Login was successful - it means that DB was not set up yet
	#	if [ -z "$dbstatus" ]; then
#
	#		# set login mode (mysql_native_password) and password for root account
	#		#echo "UPDATE mysql.user SET plugin = '', password = PASSWORD('$db_root_password') WHERE user = 'root'; FLUSH PRIVILEGES;" | sudo mysql -u root -ptemp
#
	#		# FOR UBUNTU 16.04/MariaDB 10
	#		echo "UPDATE mysql.user SET plugin = 'mysql_native_password', password = PASSWORD('$db_root_password') WHERE user = 'root'; FLUSH PRIVILEGES;" | sudo mysql -u root
#
	#		# REPLACE PASSWORD FOR MAINTANENCE ACCOUNT
	#		sudo sed -i "s/password = .*/password = $db_root_password/;" /etc/mysql/debian.cnf
#
	#		echo "DB Root access configured"
#
	#	fi
#
	#fi
	outputHandler "comment" "setting up MariaDB"
    # Do we have root password
    if [  "$(checkMariadbPassword)" = "false" ]; then

        # Checking mysql login - trying to log in without password (UBUNTU 16.04)
        dbstatus=$(sudo mysql --user=root -e exit 2>/dev/null || echo 1)

        # Checking mysql login - trying to log in with temp password (UBUNTU 14.04)
        #dbstatus=$(sudo mysql --user=root --password=temp -e exit 2>/dev/null || echo 1)

        # Login was successful - it means that DB was not set up yet
        if [ -z "$dbstatus" ]; then

            # set login mode (mysql_native_password) and password for root account
            #echo "UPDATE mysql.user SET plugin = '', password = PASSWORD('$db_root_password') WHERE user = 'root'; FLUSH PRIVILEGES;" | sudo mysql -u root -ptemp

            # FOR UBUNTU 16.04/MariaDB 10
            outputHandler "comment" "setting up password"
            echo "UPDATE mysql.user SET plugin = 'mysql_native_password', password = PASSWORD('$db_root_password1') WHERE user = 'root'; FLUSH PRIVILEGES;" | sudo mysql -u root
            outputHandler "comment" "replacing maintenance password with your new password"
            # REPLACE PASSWORD FOR MAINTANENCE ACCOUNT
            sudo sed -i "s/password = .*/password = $db_root_password1/;" /etc/mysql/debian.cnf

            outputHandler "comment" "finished setting up DB Root access"

        fi

    else
		outputHandler "comment" "Mariadb password allready set up"
	fi

else

	outputHandler "section" "Skipping Webserver configuration"
fi
