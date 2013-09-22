#!/bin/bash
#==========================================================================================================================
# Script Name:	MoodleRestore			 *Local*
# By:		Edward Owens
# Date:		May 2011
# Purpose:	Restore Moodle Root, Moodledata, and Database from the argument of 1 or 2.
#               MoodleRestore 1 will restore moodle1.zip, MoodleRestore 2 will restore moodle2.zip
#		This works in tandem with the Backup script I have created, 'MoodleBackup'.
#==========================================================================================================================

# define variables
zip1="/home/edward/Backups/moodle1.zip" 	# absolute path to backupfile 1
zip2="/home/edward/Backups/moodle2.zip" 	# absolute path to backupfile 2
lbesql="/home/edward/Backups/moodle_db.sql" 	# absolute path to sql file after extraction
logname="/home/edward/Backups/restore_log"	# absolute path to restore log
dbPassword="password"				# mysql password
dbUser="user"					# mysql user
DBNAME="databasename"				# mysql db name


DBEXISTS=$(mysql --batch --skip-column-names -e "SHOW DATABASES LIKE '"$DBNAME"';" | grep "$DBNAME" > /dev/null; echo "$?") # does database exist?

if [ $DBEXISTS -eq 0 ];then
	echo "Dropping database because it exists"
	mysqladmin -u[$dbUser] -p[$dbPassword] drop [$DBNAME]   
fi

if [ "$1" -eq "1" ]; # Want to restore backup file 1
then
	if test -e $zip1; # Does backup file 1 exist?
	then
		unzip -o $zip1 -d "/" >> $logname
		mysql -u $dbUser -p -D$DBNAME --password=$dbPassword < $lbesql 
		rm $lbesql
	else
		echo $zip1" does not exist. Make sure you run MoodleBackup first!"
		exit
	fi
else
	if [ "$1" -eq "2" ]; # Want to restore backup file 2
	then	
		if test -e $zip2; # Does backup file 2 exist?
		then
			unzip -o $zip2 -d "/" >> $logname
			mysql -u $dbUser -p -D$DBNAME --password=$dbPassword < $lbesql
			rm $lbesql
		else
			echo $zip2" does not exist. Make sure you run MoodleBackup first!"
			exit
		fi
	else
		echo "No file selected"
	fi
fi
