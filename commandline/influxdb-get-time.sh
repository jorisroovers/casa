#!/bin/bash

# config
INFLUXDB_HOST=$(cat secrets.yaml | awk '/influxdb_host/{print $2}')
INFLUXDB_PORT=$(cat secrets.yaml | awk '/influxdb_port/{print $2}')
INFLUXDB_DATABASE=$(cat secrets.yaml | awk '/influxdb_database/{print $2}')
INFLUXDB_USERNAME=$(cat secrets.yaml | awk '/influxdb_username/{print $2}')
INFLUXDB_PASSWORD=$(cat secrets.yaml | awk '/influxdb_password/{gsub(/"/, "", $2); print $2}')

QUERY=$1
# The `epoch=s` paramater in the URL makes InfluxDB return time as a unix timestamp
# This is useful so that we don't to reparse the timestamp in HA
DB_URL="http://$INFLUXDB_HOST:$INFLUXDB_PORT/query?db=$INFLUXDB_DATABASE&u=$INFLUXDB_USERNAME&p=$INFLUXDB_PASSWORD&epoch=s"
TIMESTAMP=$(curl -s -G "$DB_URL" --data-urlencode "q=$QUERY" | jq -r ".results[0].series[0].values[0][0]")
echo $TIMESTAMP