#!/usr/bin/env bash

SNAPSHOT_DIR="{{snapshot_dir}}"
THRESHOLD=250

curl "http://192.168.1.136/web/cgi-bin/hi3510/snap.cgi?&-getstream&-s" > $SNAPSHOT_DIR/snapshot-$(date +%Y-%m-%d_%H-%M-%S).jpg


num_files=$(ls $SNAPSHOT_DIR | wc -l)
diff=$(($num_files - $THRESHOLD))

echo $diff

if [ $diff -gt 0 ]; then
    echo "Threshold exceeded: cleaning up last $diff files"
    for file in $(ls $SNAPSHOT_DIR | sort -r | tail -n $diff); do
        rm $SNAPSHOT_DIR/$file
    done
fi