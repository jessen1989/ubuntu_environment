#!/bin/bash -e
outputHandler "section" "Setting up configuration files for the webserver"


if test "$install_webserver_conf" = "Y"; then
    outputHandler "comment" "Setting up Apache2"
    # Check for server name
	install_apache_servername=$(grep -E "^ServerName" /etc/apache2/apache2.conf || echo "")
	# If no results
	if [ -z "$install_apache_servername" ]; then
		outputHandler "comment" "Setting up localhost as servername"
        # SET SERVERNAME
		echo "ServerName $HOSTNAME" >> /etc/apache2/apache2.conf
        echo "" >> /etc/apache2/apache2.conf
	else
		# Replace existing servername with hostname
        outputHandler "comment" "Replacing ServerName with your computers name"
		sed -i "s/^ServerName\ [a-zA-Z0-9\.\_-]\+/ServerName\ $HOSTNAME/;" /etc/apache2/apache2.conf
	fi

	# remove path (slashes) from output to avoid problem with testing string
    install_parentnode_includes=$(grep "^IncludeOptional \/srv\/sites\/apache\/\*\.conf" /etc/apache2/apache2.conf | sed "s/\/srv\/sites\/apache\/\*\.conf//;" || echo "")
	if test -z "$install_parentnode_includes"; then
		# ADD GIT CONF SETUP
        outputHandler "comment" "including apache conf into main apache folder"
		echo "IncludeOptional /srv/sites/apache/*.conf" >> /etc/apache2/apache2.conf
		echo "" >> /etc/apache2/apache2.conf
	fi

	install_apache_access_for_srv_sites=$(grep -E "^<Directory /srv/sites>" /etc/apache2/apache2.conf || echo "")
	if [ -z "$install_apache_access_for_srv_sites" ]; then
		# Give access to /srv/sites folder from the apache configuration added to bottom of /etc/apache2/apache2.conf
		outputHandler "comment" "setting up access to /srv/sites"
		echo "" >> /etc/apache2/apache2.conf
		echo "<Directory "/srv/sites">" >> /etc/apache2/apache2.conf
		echo "	Options Indexes FollowSymLinks MultiViews" >> /etc/apache2/apache2.conf
		echo "	AllowOverride All" >> /etc/apache2/apache2.conf
		echo "	Require all granted" >> /etc/apache2/apache2.conf
		echo "</Directory>" >> /etc/apache2/apache2.conf
    	echo "" >> /etc/apache2/apache2.conf
		
	else
		outputHandler "comment" "setting up access to /srv/sites"
	fi

	# ADD DEFAULT APACHE CONF
	outputHandler "comment" "setting up default parentNode apache conf"
	cat /srv/tools/conf-client/default.conf > /etc/apache2/sites-available/default.conf
	
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

    #bash /srv/tools/scripts/install_apache.sh

    outputHandler "comment" "setting up PHP"
    # UPDATE PHP CONF
    # PHP 5
    #cat /srv/tools/conf-client/php-apache2.ini > /etc/php5/apache2/php.ini
    #cat /srv/tools/conf-client/php-cli.ini > /etc/php5/cli/php.ini

    # PHP 7.1
    #cat /srv/tools/conf-client/php-apache2.ini > /etc/php/7.1/apache2/php.ini
    #cat /srv/tools/conf-client/php-cli.ini > /etc/php/7.1/cli/php.ini
    # PHP 7.2
    #cat /srv/tools/conf-client/php-apache2.ini > /etc/php/7.2/apache2/php.ini
    #outputHandler "comment" "setting up php-cli.ini"
    #cat /srv/tools/conf-client/php-cli.ini > /etc/php/7.2/cli/php.ini
    #outputHandler "comment" "setting up apache2.ini"
    # PHP 7.4
    cat /srv/tools/conf-client/php-apache2.ini > /etc/php/7.4/apache2/php.ini
    outputHandler "comment" "setting up php-cli.ini"
    cat /srv/tools/conf-client/php-cli.ini > /etc/php/7.4/cli/php.ini
    #bash /srv/tools/scripts/install_php.sh

    if [ ! -e "/srv/sites/apache/apache.conf" ]; then
        # Add Default apache conf
        cat /srv/tools/conf-client/apache.conf > /srv/sites/apache/apache.conf
        chown $install_user:$install_user /srv/sites/apache/apache.conf
    fi

    cp "/srv/tools/conf/ssl/star_local.crt" "/srv/sites/apache/ssl/star_local.crt"
    cp "/srv/tools/conf/ssl/star_local.key" "/srv/sites/apache/ssl/star_local.key"
    apache_run_user=$(grep "export APACHE_RUN_USER" /etc/apache2/envvars | cut -d = -f2)
    if [ "$apache_run_user" = "$install_user" ]; then
        outputHandler "comment" "$install_user is Running Apache User"
    else
        sed -i 's/'"export APACHE_RUN_USER=$apache_run_user"'/'"export APACHE_RUN_USER=$install_user"'/g' /etc/apache2/envvars
    fi
    outputHandler "comment" "Restarting Apache"
    # RESTARTING APACHE ARE IMPORTANT FOR REST OF THE SCRIPT!!
    
    service apache2 restart

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

    fi
    #bash /srv/tools/scripts/install_mariadb.sh
else
    outputHandler "comment" "Skipping Webserver"
fi
