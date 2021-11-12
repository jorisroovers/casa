#!/usr/bin/env bash
set -e # Make sure we catastrophically fail so that we can never have a positive check in case of errors
source "{{backups_dir}}/backup-lib.sh"

BACKUPS_FILE_FILTER="{{backup_file_filter}}"
MAX_TIME_DIFF={{backup_max_time_diff}}
MIN_SIZE={{backup_min_size}}

last_backup=$(ls $BACKUPS_FILE_FILTER | tail -n 1)
if [ "$last_backup" == "" ]; then
    echo "Uh-oh, no backup found..."
    echo "FAIL"
    exit 2
fi

echo "Last backup found is $last_backup"
echo ""

assert_backup_age "$last_backup" $MAX_TIME_DIFF
assert_backup_size "$last_backup" $MIN_SIZE

echo "SUCCESS"
exit 0
