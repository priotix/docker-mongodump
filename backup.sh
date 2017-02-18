#!/bin/bash

set -e

echo "Job started: $(date)"

DATE=$(date +%Y%m%d_%H%M%S)
DIR="/backup"

if [[ $BACKUP_FILE_NAME ]]; then
    FILE="$DIR/$BACKUP_FILE_NAME"
else
    FILE="$DIR/$DATE"
fi

command="mongodump --quiet -h $MONGO_PORT_27017_TCP_ADDR -p $MONGO_PORT_27017_TCP_PORT --gzip"

if [[ $MONGO_DB_NAMES ]]; then
    dbs=( $MONGO_DB_NAMES )

    for d in ${dbs[@]}
    do
        if [[ ! $BACKUP_FILE_NAME ]]; then
            filename="$FILE-$d"
        fi
        eval $command " --archive=$filename -d $d"
    done
else
    eval $command " --archive=$FILE"
fi

if [[ $BACKUP_EXPIRE_DAYS ]]; then
    echo "Removing backups older than $BACKUP_EXPIRE_DAYS days"
    find $DIR -mtime +$BACKUP_EXPIRE_DAYS -type f -delete
fi

echo "Job finished: $(date)"
