#!/bin/bash -e
outputHandler "section" "Checking Software Prerequisites are met"
outputHandler "comment" "To speed up the process, please select your install options now:"
install_software_array=("[Yn]")
install_software=$(ask "Install Software (Y/n)" "${install_software_array[@]}" "option software")
export install_software

install_webserver_conf_array=("[Yn]")
install_webserver_conf=$(ask "Install Webserver Configuration (Y/n)" "${install_webserver_conf_array[@]}" "option webserver conf")
export install_webserver_conf

install_ffmpeg_array=("[Yn]")
install_ffmpeg=$(ask "Install FFMPEG (Y/n)" "${install_ffmpeg_array[@]}" "option ffmpeg")
export install_ffmpeg

install_wkhtml_array=("[Yn]")
install_wkhtml=$(ask "Install WKHTMLTOPDF (Y/n)" "${install_wkhtml_array[@]}" "option wkhtml")
export install_wkhtml

outputHandler "comment" "Apache email configuration"
if [ "$(fileExists "/etc/apache2/sites-available/default.conf")" = "true" ]; then 
	outputHandler "comment" "defaul.conf Exist"
	grep_apache_email=$(trimString "$(grep "ServerAdmin" /etc/apache2/sites-available/default.conf)")
    is_there_apache_email=$(echo "$grep_apache_email" | cut -d' ' -f2)
	
	if [ -z "$is_there_apache_email" ]; then 
		outputHandler "comment" "No apache email present"
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

createOrModifyBashProfile

outputHandler "comment" "MariaDB database password"
if test "$install_webserver_conf" = "Y"; then
	
	#Check if mariadb are installed and running
	if [ "$(checkMariadbPassword)" = "false" ]; then
		password_array=("[A-Za-z0-9\!\@\$\#]{8,30}")
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
		        echo "Password doesn't match"
		        echo
		        #password1=$( ask "Enter mariadb password" "${password_array[@]}" "Password")
		        db_root_password1=$( ask "Enter mariadb password anew" "${password_array[@]}" "password")
		        echo ""
		        db_root_password2=$( ask "Confirm mariadb password" "${password_array[@]}" "password")
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

# ## CREATE DEPLOY GROUP AND USER
install_deploy=$(grep -E "^deploy:" /etc/group || echo "")
if [ -z "$install_deploy" ]; then

	outputHandler "comment" "Creating deploy user"
	# CREATE GROUP
	groupadd deploy
	# ADD DEPLOY USER TO GROUP
	useradd -g deploy deploy
	# ADD RELEVANT USERS TO DEPLOY GROUP
	usermod -a -G deploy www-data
fi


# ADD CURRENT USER TO DEPLOY GROUP
install_deploy_user=$(grep -E "^deploy:.+$install_user" /etc/group || echo "")
if [ -z "$install_deploy_user" ]; then
	outputHandler "comment" "Adding $install_user to deploy group"
	usermod -a -G deploy $install_user
fi


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
