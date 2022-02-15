#!/usr/bin/env bash

set -eo pipefail

# This is a script to create two backups:
#  1. Creation of a full mysql backup
#  2. Creation of a minimized backup, tables prefixed with `log_` will be empty

# Global env vars
MYSQL_HOST=127.0.0.1
MYSQL_USER=root
MYSQL_PASS=""
MYSQL_PORT=3306
DB_NAME="bkp"
FILENAME="$DB_NAME.sql.gz"
FILENAME_MIN="$DB_NAME-min.sql.gz"

# Create full backup
echo "Creating full dump for $DB_NAME.."
mysqldump -h $MYSQL_HOST -u$MYSQL_USER -p"$MYSQL_PASS" \
      --single-transaction \
      --routines \
      --triggers \
      --events \
      --add-drop-database \
      --opt -B $DB_NAME -v | gzip >$FILENAME

# Filter DB tables prefixed with `log_`
LOG_TABLES=$(mysql -h $MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASS -P$MYSQL_PORT -NBe "SHOW TABLES FROM $DB_NAME LIKE 'log_%'")

# Increment the tables to be ignore, since the command line doesnt accept commas
IGNORED_LOG_TABLES=""
for table in $LOG_TABLES; do
      echo "Table $table will be ignored (empty)"
      IGNORED_LOG_TABLES+=" --ignore-table=$DB_NAME.$table"
done

echo "Creating minimized dump for $DB_NAME.."

# Create sql structure
mysqldump -h $MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASS \
      --no-data \
      --add-drop-database \
      --single-transaction $DB_NAME | gzip >$FILENAME_MIN

# Append backup with tables prefixed with `log_` empties
mysqldump -h $MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASS \
      --add-drop-database \
      --single-transaction \
      --opt -B $IGNORED_LOG_TABLES $DB_NAME | gzip >>$FILENAME_MIN

echo "Backup finished"
