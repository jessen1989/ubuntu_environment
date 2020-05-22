#!/bin/bash -e
outputHandler "section" "Checking directories"
checkFolderExistOrCreate "/home/$install_user/Sites"

if [ ! -e /srv/sites ]; then
     ln -s /home/$install_user/Sites /srv/sites
else
    sites_symlink_exists=$(ls -Fla /srv | grep /home/ | cut -d \/ -f3)
    if [ "$sites_symlink_exists" != "$install_user"  ]; then
        sudo rm /srv/sites
        sudo ln -s /home/$install_user/Sites /srv/sites
    fi
fi

checkFolderExistOrCreate "/srv/sites/apache"
checkFolderExistOrCreate "/srv/sites/apache/logs"
checkFolderExistOrCreate "/srv/sites/parentnode"
checkFolderExistOrCreate "/srv/sites/apache/ssl"

outputHandler "comment" "Changing Folder rights from root to your curent user"
# Change Folder Rights from root to current user
sudo chown -R $install_user:deploy /home/$install_user/Sites
