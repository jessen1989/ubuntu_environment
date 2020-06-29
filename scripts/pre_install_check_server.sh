#!/bin/bash -e
outputHandler "section" "Checking Software Prerequisites are met"
outputHandler "comment" "To speed up the process, please select your install options now:"

install_security_array=("[Yn]")
install_security=$(ask "Secure the server (Y/n)" "${install_security_array[@]}" "input secure the server")
export install_security

install_software_array=("[Yn]")
install_software=$(ask "Install Software (Y/n)" "${install_software_array[@]}" "input software")
export install_software


install_webserver_conf_array=("[Yn]")
install_webserver_conf=$(ask "Set up Apache/PHP/MariaDB for user (Y/n)" "${install_webserver_conf_array[@]}" "input apache/php/mariadb")
export install_webserver_conf

install_htpassword_array=("[Yn]")
install_htpassword_for_user=$(ask "Set up .htaccess for user (Y/n)" "${install_htpassword_array[@]}" "input htaccess")
export install_htpassword_for_user

install_ffmpeg_array=("[Yn]")
install_ffmpeg=$(ask "Install FFMPEG (Y/n)" "${install_ffmpeg_array[@]}" "input ffmpeg")
export install_ffmpeg

#read -p "Install wkhtmlto (Y/n): " install_wkhtml
#export install_wkhtml
install_wkhtml_array=("[Yn]")
install_wkhtml=$(ask "Install WKHTMLTOPDF (Y/n)" "${install_wkhtml_array[@]}" "input wkhtml")
export install_wkhtml
#read -p "Install mail (Y/n): " install_mail
#export install_mail
# Setting up server to send system notifications
install_mail_array=("[Yn]")
install_mail=$(ask "Install System MAIL configuration (Y/n)" "${install_mail_array[@]}" "input mail")
export install_mail

#read -p "Install Let's encrypt (Y/n): " install_letsencrypt
#export install_letsencrypt

#read -p "Your email address: " install_email
#export install_email
outputHandler "section" "Default apache email configuration."
# Setting mail address for use with system notification mail
if [ "$(fileExists "/etc/apache2/sites-available/default.conf")" = "true" ]; then 
	outputHandler "comment" "defaul.conf Exist"
	grep_apache_email=$(trimString "$(grep "ServerAdmin" /etc/apache2/sites-available/default.conf)")
    is_there_apache_email=$(echo "$grep_apache_email" | cut -d' ' -f2)
	
	if [ -z "$is_there_apache_email" ]; then 
		outputHandler "comment" "No apache email address present"
		install_email_array=("[A-Za-z0-9\.\-]+@[A-Za-z0-9\.\-]+\.[a-z]{2,10}")
		install_email=$(ask "Enter Apache email address" "${install_email_array[@]}" "apache email address")
		export install_email
	else
		install_email=$is_there_apache_email
		export install_email
	fi

	if [ "$is_there_apache_email" = "webmaster@localhost" ]; then
		outputHandler "comment" "apache email is webmaster@localhost"
		install_email_array=("[A-Za-z0-9\.\-]+@[A-Za-z0-9\.\-]+\.[a-z]{2,10}")
		install_email=$(ask "Enter Apache email address" "${install_email_array[@]}" "apache email address")
		export install_email
	fi
else 
	install_email_array=("[A-Za-z0-9\.\-]+@[A-Za-z0-9\.\-]+\.[a-z]{2,10}")
	install_email=$(ask "Enter Apache email address" "${install_email_array[@]}" "apache email address")
	export install_email
fi


# HTACCESS PASSWORD
if test "$install_htpassword_for_user" = "Y"; then
	outputHandler "section" "HTACCESS password"
	#read -s -p "HTACCESS password for $install_user: " install_htaccess_password
	password_array=("[A-Za-z0-9\!\@\$]{8,30}")
	install_htaccess_password=$( ask "HTACCESS password for $install_user" "${password_array[@]}" "password")
	export install_htaccess_password
fi


# SSH PORT
if test "$install_security" = "Y"; then
	outputHandler "section" "Provide SSH Port"
	# GET CURRENT PORT NUMBER
	port_number=$(grep -E "^Port\ ([0-9]+)$" /etc/ssh/sshd_config | sed "s/Port //;")
	#read -p "Specify SSH port (leave empty to keep $port_number): " install_port
	port_array=("[0-9]{2,6}")
	if [ -z "$port_number" ]; then
		install_port=$(ask "Specify SSH port" "${port_array[@]}" "port")
		#if [ $install_port > 65535 ]; then
		while [ "$install_port" -ge "65535" ]
		do
			outputHandler "comment" "Portnumber range to high (limit is 65535)"
			install_port=$(ask "Specify SSH port" "${port_array[@]}" "port")
		done
	else
		outputHandler "comment" "Existing ssh port: $port_number"
		override_array=("[Yn]")
		override=$(ask "Override Existing ssh port (Y/n)" "${override_array[@]}" "option for override")
		if [ "$override" = "Y" ]; then 
			install_port=$(ask "Specify new SSH port" "${port_array[@]}" "port")
		else
			install_port=$port_number
		fi
	fi
	export install_port
fi

createOrModifyBashProfile

# MYSQL ROOT PASSWORD

if test "$install_webserver_conf" = "Y"; then
	outputHandler "section" "Provide MariaDB database password"
	#Check if mariadb are installed and running
	if [ "$(checkMariadbPassword)" = "false" ]; then
		password_array=("[A-Za-z0-9\!\@\$]{8,30}")
		echo "For security measures the terminal will not display how many characters you input"
		echo ""
		echo "Password format: between 8 and 30 characters, non casesensitive letters, numbers and  # ! @ \$ special characters "
		db_root_password1=$( ask "Enter mariadb password" "${password_array[@]}" "password")
		echo ""
		db_root_password2=$( ask "Confirm mariadb password" "${password_array[@]}" "password")
		echo ""

		# While loop if not a match
		if [  "$db_root_password1" != "$db_root_password2"  ]; then
		    while [ true ]
		    do
		        outputHandler "comment" "Password Doesn't Match"
		        echo
		        #password1=$( ask "Enter mariadb password" "${password_array[@]}" "Password")
		        db_root_password1=$( ask "Enter mariadb password anew" "${password_array[@]}" "password")
		        echo ""
		        db_root_password2=$( ask "Confirm mariadb password" "${password_array[@]}" "password")
		        echo "" 
		        if [ "$db_root_password1" == "$db_root_password2" ];
		        then
		            outputHandler "comment" "Password Match"
		            break
		        fi
		        export db_root_password1
		    done
		else
		    outputHandler "comment" "Password Match"
			export db_root_password1
		fi
	else 
		outputHandler "comment" "Mariadb password allready set up"
	fi	
fi


# SETTING DEFAULT GIT USER
outputHandler "section" "Setting GIT User setting"
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

outputHandler "section" "Time zone"

#look_for_ex_timezone=$(sudo timedatectl status | grep "Time zone: " | cut -d ':' -f2)
#if [ -z "$look_for_ex_timezone" ]; then
#	outputHandler "comment" "Setting Time zone to Europe/Copenhagen"
#	sudo timedatectl set-timezone "Europe/Copenhagen"
#else 
#	outputHandler "comment" "Existing time zone values: $look_for_ex_timezone"
#fi
outputHandler "comment" "Setting Time zone to Europe/Copenhagen"
sudo timedatectl set-timezone "Europe/Copenhagen"