#!/bin/bash
#==========================================================================================================================
# Script Name:	LocalMoodleBackup
# By:		Edward Owens
# Date:		April 2011
# Purpose:	Backup Moodle, Moodledata, and Database and zip them in a single zip file. Keep only two backups on hand. 
#               If there is already two backups on hand, then overwrite the oldest one.
#==========================================================================================================================

#------Variables-----------------------------------------------------------------------------------------------------------
suffix=$(date +%B-%Y)					# date stamp
logname="/home/edward/Backups/"$suffix"_backup.log"	# absolute path to logfile
file_name1="/home/edward/Backups/moodle1.zip"		# absolute path to backup 1
file_name2="/home/edward/Backups/moodle2.zip"		# absolute path to backup 2
zip1="/home/edward/webdev/domainname.com/"		# absolute path to moodle root
zip2="/home/edward/webdev/moodledata/"			# absolute path to moodle data
sql_name="/home/edward/Backups/moodle_db.sql"		# absolute path to sql file
dbName="my dbname"					# db Name
dbUser="my dbuser"					# db User
dbPassword="mypassword"					# db Password
dbHost="my dbhost"					# db Host
#----------------------------------------------------------------------------------------------------------------------------

echo "Started--> "$(date +%H":"%M":"%S) > $logname
echo "Dumping database"
mysqldump --opt --user=$dbUser --password=$dbPassword --host=$dbHost $dbName > $sql_name

if test -e $file_name1;
then
	if test -e $file_name2;
	then
		echo "copying moodle2.zip to moodle1.zip"
		cp $file_name2 $file_name1 >> $logname
		echo "removing moodle2.zip"
		rm $file_name2 >> $logname
		echo "creating moodle2.zip"
		zip -r $file_name2 $zip1 $zip2 $dbname >> $logname
	else
		echo "creating moodle2.zip"
		zip -r $file_name2 $zip1 $zip2 $dbname >> $logname
	fi
else
	echo "creating moodle1.zip"
	zip -r $file_name1 $zip1 $zip2 $dbname >> $logname
fi

# remove sql file
echo "removing "$sql_name
rm $sql_name
echo "Finished--> "$(date +%H":"%M":"%S) >> $logname
echo "Finished--> "$(date +%H":"%M":"%S)
