#!/usr/bin/env bash
set -e # Make sure we catastrophically fail so that we can never have a positive check in case of errors

GITHUB_BACKUPS_DIRECTORY="{{github_backups_dir}}"
NOW=$(date +%s)
MAX_TIME_DIFF=$((60 * 60 * 12)) # 12 hours
MIN_SIZE=$((1024 * 1024 * 22)) # 22 MB (= size at time of writing script, backup will only grow)

last_backup="${GITHUB_BACKUPS_DIRECTORY}/$(ls $GITHUB_BACKUPS_DIRECTORY | tail -n 1)"
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