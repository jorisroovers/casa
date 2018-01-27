HOMEASSISTANT_DB="{{influxdb_homeassistant_db}}"
influxd backup -database "$HOMEASSISTANT_DB" "$DIRECTORY"