#!/usr/bin/env bash
source "{{backups_dir}}/backup-lib.sh"

BACKUPS_FILE_FILTER="{{backup_file_filter}}"
last_backup=$(ls $BACKUPS_FILE_FILTER | tail -n 1)

# Set values to -1 if no backup exists
backup_timestamp=$(stat -c %Y "$last_backup" || echo "-1")
backup_size=$(stat -c %s "$last_backup"  || echo "-1")

# Execute backup check script, get status
# We could also just collect the stats and setup the monitoring in prometheus, but this is extra work and complexity
# with really little benefit at this point.
echo "Executing {{backup_monitoring_script}}"
echo "-----------------------------------------------------------------------------------------------------------------"
{{backup_monitoring_script}}
backup_check_status=$?
echo "-----------------------------------------------------------------------------------------------------------------"
echo "Writing prometheus metrics to {{node_exporter_textfile_exports}}/{{backup_type}}.prom"

# Output .prom file so prometheus (or more specifically node_exporter) can pick up the metrics
cat << EOF > {{node_exporter_textfile_exports}}/{{backup_type}}.prom
# HELP custom_backup_size Custom Backup Size
# TYPE custom_backup_size gauge
custom_backup_size{name="{{backup_type}}"} $backup_size
# HELP custom_backup_timestamp Custom Backup Timestamp
# TYPE custom_backup_timestamp gauge
custom_backup_timestamp{name="{{backup_type}}"} $backup_timestamp
# HELP custom_backup_check_status Custom Backup Check status
# TYPE custom_backup_check_status gauge
custom_backup_check_status{name="{{backup_type}}"} $backup_check_status
EOF

echo "DONE"