#!/bin/bash -e

echo
echo "To speed up the process, please select your install options now:"
echo

read -p "Secure the server (Y/n): " install_security
export install_security

read -p "Install software (Y/n): " install_software
export install_software

read -p "Set up Apache/PHP/MariaDB (Y/n): " install_webserver_conf
export install_webserver_conf

read -p "Install .htaccess (Y/n): " install_htpassword_for_user
export install_htpassword_for_user

read -p "Install ffmpeg (Y/n): " install_ffmpeg
export install_ffmpeg

#read -p "Install wkhtmlto (Y/n): " install_wkhtml
#export install_wkhtml
install_wkhtml_array=("[Yn]")
install_wkhtml=$(ask "Install WKHTMLTOPDF (Y/n)" "${install_wkhtml_array[@]}" "option wkhtml")
export install_wkhtml

#read -p "Install mail (Y/n): " install_mail
#export install_mail

#read -p "Install Let's encrypt (Y/n): " install_letsencrypt
#export install_letsencrypt

read -p "Your email address: " install_email
export install_email

# HTACCESS PASSWORD
if test "$install_htpassword_for_user" = "Y"; then

	read -s -p "HTACCESS password for $install_user: " install_htaccess_password

	export install_htaccess_password
	echo
	echo

fi

# SSH PORT
if test "$install_security" = "Y"; then

	# GET CURRENT PORT NUMBER
	port_number=$(grep -E "^Port\ ([0-9]+)$" /etc/ssh/sshd_config | sed "s/Port //;")

	read -p "Specify SSH port (leave empty to keep $port_number): " install_port
	export install_port
	echo

fi

outputHandler "comment" "Apache email configuration"
if [ "$(fileExists "/etc/apache2/sites-available/default.conf")" = "true" ]; then 
	outputHandler "comment" "defaul.conf Exist"
	grep_apache_email=$(trimString "$(grep "ServerAdmin" /etc/apache2/sites-available/default.conf)")
    is_there_apache_email=$(echo "$grep_apache_email" | cut -d' ' -f2)
	
	if [ -z "$is_there_apache_email" ]; then 
		echo "No apache email present"
		install_email_array=("[A-Za-z0-9\.\-]+@[A-Za-z0-9\.\-]+\.[a-z]{2,10}")
		install_email=$(ask "Enter Apache email" "${install_email_array[@]}" "apache email")
		export install_email
	else
		install_email=$is_there_apache_email
		export install_email
	fi

	if [ "$is_there_apache_email" = "webmaster@localhost" ]; then
		echo "apache email is webmaster@localhost"
		install_email_array=("[A-Za-z0-9\.\-]+@[A-Za-z0-9\.\-]+\.[a-z]{2,10}")
		install_email=$(ask "Enter Apache email" "${install_email_array[@]}" "apache email")
		export install_email
	fi
else 
	install_email_array=("[A-Za-z0-9\.\-]+@[A-Za-z0-9\.\-]+\.[a-z]{2,10}")
	install_email=$(ask "Enter Apache email" "${install_email_array[@]}" "apache email")
	export install_email
fi
createOrModifyBashProfile

# MYSQL ROOT PASSWORD
outputHandler "comment" "MariaDB password"
if test "$install_webserver_conf" = "Y"; then
	
	#Check if mariadb are installed and running
	if [ "$(checkMariadbPassword)" = "false" ]; then
		password_array=("[A-Za-z0-9\!\@\$]{8,30}")
		db_root_password1=$( ask "Enter mariadb password" "${password_array[@]}" "password")
		echo ""
		db_root_password2=$( ask "Enter mariadb password again" "${password_array[@]}" "password")
		echo ""

		# While loop if not a match
		if [  "$db_root_password1" != "$db_root_password2"  ]; then
		    while [ true ]
		    do
		        echo "Password doesn't match"
		        echo
		        #password1=$( ask "Enter mariadb password" "${password_array[@]}" "Password")
		        db_root_password1=$( ask "Enter mariadb password" "${password_array[@]}" "password")
		        echo ""
		        db_root_password2=$( ask "Enter mariadb password again" "${password_array[@]}" "password")
		        echo "" 
		        if [ "$db_root_password1" == "$db_root_password2" ];
		        then
		            echo "Password Match"
		            break
		        fi
		        export db_root_password1
		    done
		else
		    echo "Password Match"
			export db_root_password1
		fi
	else 
		outputHandler "comment" "Mariadb password allready set up"
	fi	
fi


# SETTING DEFAULT GIT USER
outputHandler "comment" "Setting Default GIT User setting"
# SETTING DEFAULT GIT USER

# Checks if git credential are allready set, promts for input if not
if [ -z "$(checkGitCredential "name")" ]; then
	git_username_array=("[A-Za-z0-9[:space:]*]{2,50}")
	git_username=$(ask "Enter git username" "${git_username_array[@]}" "git username")
	export git_username
else
	git_username="$(checkGitCredential "name")"
	export git_username
fi
if [ -z "$(checkGitCredential "email")" ]; then
	git_email_array=("[A-Za-z0-9\.\-]+@[A-Za-z0-9\.\-]+\.[a-z]{2,10}")
	git_email=$(ask "Enter git email" "${git_email_array[@]}" "git email")
	export git_email
else
	git_email="$(checkGitCredential "email")"
	export git_email
fi
git config --global core.filemode false
outputHandler "comment" "git core.filemode: $(git config --global core.filemode)"
git config --global user.name "$git_username"
outputHandler "comment" "git user name: $(git config --global user.name)"
git config --global user.email "$git_email"
outputHandler "comment" "git user email: $(git config --global user.email)"
git config --global credential.helper cache
outputHandler "comment" "git credential.helper: $(git config --global credential.helper)"

outputHandler "comment" "Setting Time zone"

look_for_ex_timezone=$(sudo timedatectl status | grep "Time zone: " | cut -d ':' -f2)
if [ -z "$look_for_ex_timezone" ]; then
	outputHandler "comment" "Setting Time zone to Europe/Copenhagen"
	sudo timedatectl set-timezone "Europe/Copenhagen"
else 
	outputHandler "comment" "Existing time zone values: $look_for_ex_timezone"
fi