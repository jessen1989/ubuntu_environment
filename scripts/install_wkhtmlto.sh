#!/bin/bash -e
outputHandler "comment" "WKHTML"
outputHandler "comment" "http://wkhtmltopdf.org - LGPLv3"

if test "$install_wkhtml" = "Y"; then

	# WKHTML - FORCE PASSWORD RENEWAL
	outputHandler "comment" "Installing wkhtmltopdf into tools"
	sudo tar -xzvf /srv/tools/bin/wkhtml.tar.gz -C /srv/tools/bin/
	#sudp cp /home/$install_user/wkhtmltopdf /srv/tools/bin/
	sudo rm /srv/tools/bin/wkhtml.tar.gz
	/srv/tools/bin/wkhtmltopdf --version
	#sudo apt install -y wkhtmltopdf
	# installedPackage "wkhtmltopdf"
	# sudo cp /srv/tools/conf/wkhtmltoimage /usr/bin/static_wkhtmltoimage
	# sudo cp /srv/tools/conf/wkhtmltopdf /usr/bin/static_wkhtmltopdf
	#wget https://downloads.wkhtmltopdf.org/0.12/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
	#wget http://download.gna.org/wkhtmltopdf/0.12/0.12.3/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz
	
	#sudo wget -P Downloads https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb 
	#cd ~/Downloads
	#sudo apt install xfonts-75dpi
	#sudo apt install xfonts-base
	#sudo dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb 
	#sudo cp /usr/local/bin/wkhtmltopdf /srv/tools/bin/wkhtmltopdf

else
	outputHandler "comment" "skipping WKHTML"
fi

