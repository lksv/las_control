#!/bin/sh

ROOTDIR=/home/deployer/las/las_control
DIR=`date +%F`
BACKUPFILE_FILES="/tmp/mapasamospravy_dir_backup_`date +%F-%H-%M-%S`.tar.bz2"
BACKUPFILE_DB="/tmp/mapasamospravy_db_backup_`date +%F-%H-%M-%S`.dump"
BACKUPFILE_LOG="/tmp/mapasamospravy_backup_`date +%F-%H-%M-%S`.log"

tar -cvjP \
  --exclude $ROOTDIR/tmp \
  --exclude $ROOTDIR/public/static_cache \
  --exclude $ROOTDIR/public/system \
  --exclude $ROOTDIR/public/cache \
  --exclude $ROOTDIR/vendor \
  --exclude $ROOTDIR/clinet/node_modules \
  --exclude $ROOTDIR/log \
  --exclude $ROOTDIR/elasticsearch.log \
  -f $BACKUPFILE_FILES $ROOTDIR > $BACKUPFILE_LOG

PGPASSWORD=$DB_PASSWORD pg_dump -h $DB_HOST -U $DB_USERNAME -Fc $DB_PRODUCTION_DATABASE > $BACKUPFILE_DB

(
  echo "
  put $BACKUPFILE_DB
  put $BACKUPFILE_FILES
  put $BACKUPFILE_LOG
  bye
    "
) | lftp -p 2004 sftp://${BACKUP_USER}:${BACKUP_PASS}@${BACKUP_HOST}${BACKUP_HOST_DIR} && rm $BACKUPFILE_FILES $BACKUPFILE_DB $BACKUPFILE_LOG

