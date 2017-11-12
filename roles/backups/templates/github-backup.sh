#!/bin/bash
# TODO(jorisroovers): support private repositories

############################################################################################
# Config

PARENT_DIRECTORY="{{github_backups_dir}}"
BACKUP_NAME="github-backup-$(date +'%Y-%m-%d_%H-%M-%S')"
DIRECTORY="${PARENT_DIRECTORY}/$BACKUP_NAME"
USERNAME="{{github_username}}"
BACKUP_RETENTION_COUNT=3

#  COLORS
GREEN="\e[32m"
NO_COLOR="\e[0m"

###########################################################################################
# Cleaning up any old backups that we don't need to keep anymore

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

###########################################################################################
# Creating the new backup

set -e # Fail the entire script if anything fails after this
echo "Creating $DIRECTORY"
mkdir -p "$DIRECTORY"
cd "$DIRECTORY"

echo "Fetching list of repositories..."
# For now, we only back up non-forked repos. This is because some of the forks are pretty large
REPOSITORIES="$(curl -s "https://api.github.com/users/${USERNAME}/repos" | jq -r '.[] | select(.fork == false) | .html_url')"

echo "Downloading repositories..."
for repository in $REPOSITORIES; do
    echo "Git Cloning ${repository}..."
    git clone $repository
done

echo "Creating tarball of ${DIRECTORY}..."
cd $PARENT_DIRECTORY
# IMPORTANT: Don't add quotes around the '-C ${DIRECTORY}/*' part below, that will break the backup
tar -czvf "${BACKUP_NAME}.tar.gz" -C ${DIRECTORY}/*

echo "Removing work directory ${DIRECTORY}"
rm -rf "$DIRECTORY"
echo -e "${GREEN}ALL DONE${NO_COLOR}"

###########################################################################################
# TODO: Store backup on NAS

