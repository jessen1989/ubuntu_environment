# Usage
# crontab: 45 3 * * * /srv/tools/scripts/dataprotectionplan.sh #DB# #RECIPIENT1[,RECIPIENT2]#

# Username and Password must be found in /srv/crons/conf/db/#DB# as username|password (no newline)
#
# Remember to set appropriate permissions for cron configs 
# sudo chown -R root:root /srv/crons/conf
# sudo chmod -R 600 /srv/crons/conf


echo "DATAPROTECTIONPLAN FOR $1"
echo "- read username and passwod"
echo "- dump database"
echo "- make zipped tarball"
echo "- encrypt data"
echo "- send as email"


if [ -e "/srv/crons/conf/db/$1" ]; then

	# read username and password from conf file
	config=$(cat "/srv/crons/conf/db/$1")

	# not working in sh and cronjob runs as sh (not bash)
	# config=$(<"/srv/crons/conf/db/$1")

	# split string
	username=${config%|*}
	password=${config#*|}


	# dump data
	mysqldump -u $username -p$password $1 > $1.sql

	# make tarball
	tar -czvf $1.sql.tar.gz $1.sql

	# encrypt
	openssl aes-128-cbc -k $password < $1.sql.tar.gz > $1.sql.tar.gz.aes

	# decryption done by
	# openssl aes-128-cbc -d < yourfile.txt.aes > yourfile.txt

	# send file
	echo "You are welcome :)" | mail -s "DATA PROTECTION PLAN FOR $1" -A $1.sql.tar.gz.aes $2


	# clean up
	rm $1.sql
	rm $1.sql.tar.gz
	rm $1.sql.tar.gz.aes

	echo
	echo "Data is sent - clean up is done"

else

	echo "Password file is missing for $1"

fi
