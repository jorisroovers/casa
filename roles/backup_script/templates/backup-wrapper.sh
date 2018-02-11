#!/bin/bash

BACKUP_TYPE="{{backup_type}}"
source "{{backups_dir}}/backup-lib.sh"

############################################################################################
create_backup_dir
purge_old_backups
set -e # Fail the entire script if anything fails after this
new_work_dir

###########################################################################################
# Actual backup logic
{{script_content}}

create_tarball
cleanup_work_dir

echo -e "${GREEN}ALL DONE${NO_COLOR}"

###########################################################################################
# TODO: Store backup on NAS
