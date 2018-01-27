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

function purge_old_backups(){
    num_backups=$(ls $PARENT_DIRECTORY | wc -l)
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


