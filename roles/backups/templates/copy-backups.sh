#!/bin/bash
# Bash script that copies the latest backups in the backups dir to an external dir

############################################################################################
# Config
BACKUPS_DIRECTORY="{{backups_dir}}"
TARGET_PARENT_DIRECTORY="{{backups_external_copy_path}}"
TARGET_DIRECTORY="${TARGET_PARENT_DIRECTORY}/$(date +'%Y-%m-%d_%H-%M-%S')"
BACKUP_RETENTION_COUNT=3

#  COLORS
GREEN="\e[32m"
NO_COLOR="\e[0m"
############################################################################################

# Purge old backups if count is exceeded
num_backups=$(ls -d $TARGET_PARENT_DIRECTORY/*/ | wc -l)
diff=$(($num_backups - $BACKUP_RETENTION_COUNT))

if [ $diff -gt 0 ]; then
    echo "Threshold of $BACKUP_RETENTION_COUNT exceeded: cleaning up last $diff backups..."
    for directory in $(ls -d $TARGET_PARENT_DIRECTORY/*/  | sort -r | tail -n $diff); do
        echo -e "  Deleting $directory"
        rm -rf "$directory"
    done
    echo -e "${GREEN}DONE${NO_COLOR}"
fi

############################################################################################

echo "Creating target directory ${TARGET_DIRECTORY}..."
mkdir "${TARGET_DIRECTORY}"

############################################################################################

# List all directories
# NOTE: trailing slash is important, and don't add quotes, otherwise the globbing doesn't work
backup_types=$(ls -d $BACKUPS_DIRECTORY/*/data/)

for backup_type_dir in $backup_types; do
    last_backup=$(ls ${backup_type_dir}*.tar.gz | tail -n 1)
    echo "Copying $last_backup to $TARGET_DIRECTORY..."
    cp "$last_backup" "$TARGET_DIRECTORY"
done

echo -e "${GREEN}ALL DONE${NO_COLOR}"
