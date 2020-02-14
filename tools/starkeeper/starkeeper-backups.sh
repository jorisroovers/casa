#!/bin/sh
BACKUP_DIR="/mnt/samsungT5/Backups/starkeeper"

sysupgrade -b $BACKUP_DIR/backup-${HOSTNAME}-$(date +'%Y-%m-%d_%H-%M-%S').tar.gz

# Ensure we flush to persistent storage on SSD
sync