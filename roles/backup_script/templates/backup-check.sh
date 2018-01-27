#!/usr/bin/env bash
set -e # Make sure we catastrophically fail so that we can never have a positive check in case of errors

BACKUPS_DIRECTORY="{{backups_dir}}/{{backup_type}}"
NOW=$(date +%s)
MAX_TIME_DIFF={{backup_max_time_diff}}
MIN_SIZE={{backup_min_size}}

last_backup="${BACKUPS_DIRECTORY}/$(ls $BACKUPS_DIRECTORY | tail -n 1)"
echo "Last backup found is $last_backup"

# Check max backup age
backup_timestamp=$(stat -c %Y "$last_backup")
timediff=$(($NOW - $backup_timestamp))
echo "The backup is $timediff secs old"
if [ $timediff -gt $MAX_TIME_DIFF ]; then
    echo "Uh-oh, that's longer than the max age of $MAX_TIME_DIFF secs..."
    echo "FAIL"
    exit 2
fi
echo "That's within the max threshold of $MAX_TIME_DIFF seconds"
echo ""

# Check min backup size
size=$(stat -c %s "$last_backup")
echo "The backup is $size bytes"

if [ $size -lt $MIN_SIZE ]; then
    echo "Uh-oh, that's smaller than the min expected size of $MIN_SIZE bytes..."
    echo "FAIL"
    exit 2
fi

echo "That's larger than the min threshold of $MIN_SIZE bytes"

echo "SUCCESS"
exit 0