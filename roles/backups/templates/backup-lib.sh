#!/bin/bash

# Expected variables set:
# - BACKUP_TYPE

############################################################################################
# Config
PARENT_DIRECTORY="{{backups_dir}}/$BACKUP_TYPE"
BACKUP_NAME="$BACKUP_TYPE-backup-$(date +'%Y-%m-%d_%H-%M-%S')"
DIRECTORY="${PARENT_DIRECTORY}/$BACKUP_NAME"

#  COLORS
GREEN="\e[32m"
NO_COLOR="\e[0m"

BACKUP_RETENTION_COUNT=3
############################################################################################
# Backup functions

function purge_old_backups(){
    num_backups=$(ls $PARENT_DIRECTORY/*.tar.gz | wc -l)
    diff=$(($num_backups - $BACKUP_RETENTION_COUNT))

    if [ $diff -gt 0 ]; then
        echo "Threshold of $BACKUP_RETENTION_COUNT exceeded: cleaning up last $diff backups..."
        for tarball in $(ls $PARENT_DIRECTORY | sort -r | tail -n $diff); do
            echo -e "  Deleting $PARENT_DIRECTORY/$tarball"
            rm -rf "$PARENT_DIRECTORY/$tarball"
        done
        echo -e "${GREEN}DONE${NO_COLOR}"
    fi
}

function create_backup_dir(){
    mkdir -p "$PARENT_DIRECTORY"
}

function new_work_dir(){
    echo "Creating $DIRECTORY"
    mkdir -p "$DIRECTORY"
    cd "$DIRECTORY"
}

function cleanup_work_dir(){
    echo "Removing work directory ${DIRECTORY}"
    rm -rf "$DIRECTORY"
}

function create_tarball(){
    echo "Creating tarball of ${DIRECTORY}..."
    cd $PARENT_DIRECTORY
    # tar -czvf "${BACKUP_NAME}.tar.gz" -C ${DIRECTORY}/*
    tar -czvf "${BACKUP_NAME}.tar.gz" -C ${DIRECTORY} .

}

##########################################################################################
# Check functions

function assert_backup_age(){
    backup_path="$1"
    max_time_diff="$2"
    now=$(date +%s)
    # Check max backup age
    backup_timestamp=$(stat -c %Y "$backup_path")
    timediff=$(($now - $backup_timestamp))
    echo "The backup is $timediff secs old"
    if [ $timediff -gt $max_time_diff ]; then
        echo "Uh-oh, that's longer than the max age of $max_time_diff secs..."
        echo "FAIL"
        exit 2
    fi
    echo "That's within the max threshold of $max_time_diff seconds"
    echo ""
}

function assert_backup_size(){
    backup_path="$1"
    echo "PATH: $backup_path"
    min_size="$2"
    size=$(stat -c %s "$backup_path")
    echo "The backup is $size bytes"

    if [ $size -lt $min_size ]; then
        echo "Uh-oh, that's smaller than the min expected size of $min_size bytes..."
        echo "FAIL"
        exit 2
    fi

    echo "That's larger than the min threshold of $min_size bytes"
}


