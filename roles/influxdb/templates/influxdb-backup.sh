HOMEASSISTANT_DB="{{influxdb_homeassistant_db}}"
SENSU_DB="{{influxdb_sensu_db}}"
influxd backup -database "$HOMEASSISTANT_DB" "$DIRECTORY/$HOMEASSISTANT_DB"
influxd backup -database "$SENSU_DB" "$DIRECTORY/$SENSU_DB"