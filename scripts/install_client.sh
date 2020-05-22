#!/bin/bash -e

echo "--------------------------------------------------------------"
echo ""
echo "Installing parentNode in ubuntu"
echo "DO NOT CLOSE UNTIL INSTALL ARE COMPLETE" 
echo "You will see 'Install complete' message once it's done"
echo ""
echo ""


source /srv/tools/scripts/functions.sh
enableSuperCow
ubuntu_version=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -d \= -f2)
outputHandler "comment" "You are running ubuntu version: $ubuntu_version"
# GET INSTALL USER
install_user="$(getUsername)"
#$(whoami | awk '{print $1}')
export install_user
outputHandler "comment" "Installing system for $install_user"

# Check software prerequisites is met
. /srv/tools/scripts/pre_install_check_client.sh

# Checking directories
. /srv/tools/scripts/checking_directories_client.sh

# INSTALL SOFTWARE
. /srv/tools/scripts/install_software.sh

# Setting up configuration files for the webserver
. /srv/tools/scripts/post_install_setup_client.sh




# Change Folder Rights from root to current user
#outputHandler "comment" "Changing folder rights from root to $install_user"
#sudo chown -R $install_user:deploy /home/$install_user/Sites


echo ""
echo "parentNode installed in Ubuntu "
echo ""
outputHandler "comment" "Link to information regarding this script" "https://parentnode.dk/blog/installing-the-web-stack-on-an-ubuntu-client"
outputHandler "section" "Install complete"
echo "--------------------------------------------------------------"
echo ""

