#!/bin/bash
########################################################################################################################
# CONFIG

STATUS=0
TMP_DIR="/tmp/backup-check/influxdb/"
LAST_BACKUP=$(ls {{backups_external_copy_path}}/$(ls {{backups_external_copy_path}}/ | tail -n 1)/influxdb*)
INFLUX_USERNAME="{{influxdb_admin_user}}"
INFLUX_PASSWORD="{{influxdb_admin_password}}"
INFLUX_HOST="0.0.0.0"

########################################################################################################################
# Cleanup previous runs of this script
echo "****** $(date +'%Y-%m-%d %H:%M:%S %Z') ******"
echo "Testing out influxDB backup restoration in $TMP_DIR"
echo -n "Cleaning up any previous backup restoration attempts..."
rm -rf $TMP_DIR
mkdir -p $TMP_DIR
influx -ssl --unsafeSsl -username "$INFLUX_USERNAME" -password "$INFLUX_PASSWORD" \
       -host "$INFLUX_HOST" -execute "DROP DATABASE \"backup-restore-test-homeassistant\""
echo "DONE"

########################################################################################################################
# Copy + extract latest backup

cd $TMP_DIR
echo "Last backup: $LAST_BACKUP"
echo -n "Copying $LAST_BACKUP to $TMP_DIR"
cp $LAST_BACKUP $TMP_DIR # latest copy
STATUS=$(( $STATUS + $? ))
echo "DONE (STATUS=$STATUS)"

echo "Extracting backup..."
tar xvf $TMP_DIR/*tar.gz
STATUS=$(( $STATUS + $? ))
echo "DONE (STATUS=$STATUS)"

########################################################################################################################
# Restore DB

# truncate --size=1M $TMP_DIR/homeassistant/*

if [ $STATUS -eq 0 ]; then
	echo "Attempting DB restore..."
	influxd restore -portable -db homeassistant -newdb backup-restore-test-homeassistant $TMP_DIR/homeassistant/
	STATUS=$(( $STATUS + $? ))
	echo "DONE (STATUS=$STATUS)"

	if [ $STATUS -eq 0 ]; then
		echo -n "Quick sanity check on the data..."
		sleep 5 # Need to sleep a bit, otherwise influxdb isn't ready for our query yet
		NR_SERIES=$(influx -ssl --unsafeSsl -username "$INFLUX_USERNAME" -password "$INFLUX_PASSWORD" -host "$INFLUX_HOST" -database backup-restore-test-homeassistant -execute "SHOW SERIES CARDINALITY" | tail -n 1)
		$(test $NR_SERIES -gt 200)
		STATUS=$(( $STATUS + $? ))
		echo "DONE (STATUS=$STATUS)"
	fi
fi

########################################################################################################################
# Write results to prometheus file

PROM_FILE="{{node_exporter_textfile_exports}}/influxdb-backup-restore-check.prom"
echo -n "Writing status (=$STATUS) to $PROM_FILE ..."

cat << EOF > $PROM_FILE
# HELP custom_backup_check_status Custom Backup Check status
# TYPE custom_backup_check_status gauge
custom_backup_check_status{name="influxdb-backup-restore-check"} $STATUS
EOF
echo "DONE"

########################################################################################################################
# Clean up restored test DB

echo -n "Cleaning test DB..."
influx -ssl --unsafeSsl -username "$INFLUX_USERNAME" -password "$INFLUX_PASSWORD" \
      -host "$INFLUX_HOST" -execute "DROP DATABASE \"backup-restore-test-homeassistant\""
echo "DONE"
exit $STATUS