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
mkdir -p $HOME/backups
p=$HOME/backups
suffix=$(date +%B-%Y)					# date stamp
file_name1=$p"/moodle1.zip"		# absolute path to backup 1
file_name2=$p"/moodle2.zip"		# absolute path to backup 2
lbesql=$p"/moodle_db.sql"		# absolute path to sql file
logname=$p"/"$suffix"_restore.log"	# absolute path to logfile
dbPassword="rootpass"				# mysql password
dbUser="root"					# mysql user
DBNAME="moodle"				# mysql db name

sudo service apache2 stop

if [ ! -f $file_name1 ];then
  echo "There is no backup file at the location of $file_name1. Make sure you run MoodleBackup first!"
  exit
fi

DBEXISTS=$(mysql --user=$dbUser --password=$dbPassword --batch --skip-column-names -e "SHOW DATABASES LIKE '"$DBNAME"';" | grep "$DBNAME" > /dev/null; echo "$?") # does the database already exist?
if [ $DBEXISTS -eq 0 ];then
  echo "Dropping database because it exists"
  mysqladmin -f --user=$dbUser --password=$dbPassword drop $DBNAME
fi

restore(){
  unzip -o $1 -d "/" >> $logname
  mysql --user=$dbUser --password=$dbPassword --execute="create database if not exists $DBNAME"
  mysql --user=$dbUser --password=$dbPassword --database=$DBNAME < $lbesql 
  rm $lbesql
}

if [ -f $file_name2 ];then
  restore $file_name2
elif [ -f $file_name1 ];then
  restore $file_name1
fi

sudo service apache2 start


