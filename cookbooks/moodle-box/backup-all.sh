#!/bin/bash
#==========================================================================================================================
# Script Name:	LocalMoodleBackup
# By:		Edward Owens
# Date:		April 2011
# Purpose:	Backup Moodle, Moodledata, and Database and zip them in a single zip file. Keep only two rolling backups of 300MB each on hand. 
#               If you have a moodle2.zip file, then this is the latest version.
# Modified at:  September 2013
# Modified by:  nikolaos.maris@epfl.ch
#==========================================================================================================================

#------Variables-----------------------------------------------------------------------------------------------------------
# TODO: make the code portable
mkdir -p $HOME/backups
p=$HOME/backups
suffix=$(date +%B-%Y)					# date stamp
logname=$p"/"$suffix"_backup.log"	# absolute path to logfile
file_name1="/vagrant/moodle1.zip"		# absolute path to backup 1
file_name2="/vagrant/moodle2.zip"		# absolute path to backup 2
zip1="/usr/local/moodle/"		# absolute path to moodle root
zip2="/var/lib/moodle/"			# absolute path to moodle data
dbscript=$p"/moodle_db.sql"		# absolute path to sql file
dbName="moodle"					# db Name
dbUser="root"					# db User
dbPassword="rootpass"					# db Password
dbHost="0.0.0.0"					# db Host
#----------------------------------------------------------------------------------------------------------------------------

echo "Started--> "$(date +%H":"%M":"%S) > $logname
echo "Dumping database"
mysqldump --opt --user=$dbUser --password=$dbPassword --host=$dbHost $dbName > $dbscript

if test -e $file_name1
then
	if test -e $file_name2
	then
		echo "copying moodle2.zip to moodle1.zip"
		cp $file_name2 $file_name1 >> $logname
		echo "removing moodle2.zip"
		rm $file_name2 >> $logname
		echo "creating moodle2.zip"
		zip -r $file_name2 $zip1 $zip2 $dbscript >> $logname
	else
		echo "creating moodle2.zip"
		zip -r $file_name2 $zip1 $zip2 $dbscript >> $logname
	fi
else
	echo "creating moodle1.zip"
	zip -r $file_name1 $zip1 $zip2 $dbscript >> $logname
fi

# remove sql file
echo "removing "$dbscript
rm $dbscript
echo "Finished--> "$(date +%H":"%M":"%S) >> $logname
echo "Finished--> "$(date +%H":"%M":"%S)
