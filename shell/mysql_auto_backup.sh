#!/bin/bash
#######################################################
# $Name:         mysql_auto_backup.sh
# $Version:      1.0
# $Function:     Backup MySQL Databases Script
# $Author:       skywalkerwie
# $organization: https://github.com/skywalkerwei
# $Description:  定期备份MySQL数据库
# $Crontab:      10 3 * * *  bash ./backup/mysql_auto_backup.sh >/dev/null 2>&1
#######################################################

# Shell Env
SHELL_NAME="mysql_auto_backup.sh"

BASE_PATH="DB"

# get current time
CURRENT_TIME=$(date '+%Y-%m-%d-%H:%M:%S')

# get data eg：201911
# DIR_NAME=$(date +%s)
DIR_NAME=`date "+%Y-%m-%d"`  
# db name
DB_NAME="base"

# backup path
BACKUP_PATH=$BASE_PATH/$DB_NAME/$DIR_NAME/

# backup sql file name
BACKUP_NAME=${DB_NAME}".sql"

# create log directory
mkdir -p $BACKUP_PATH

# run docker
RES=$(docker exec dnmp-mysql mysqldump  --defaults-extra-file=/etc/mysql/conf.d/mysql.cnf  $DB_NAME > $BACKUP_NAME)
echo $CURRENT_TIME-"备份结果："$? 
mv $BACKUP_NAME  $BACKUP_PATH