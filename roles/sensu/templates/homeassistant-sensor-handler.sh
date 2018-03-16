#!/bin/bash
###############################################################################
# Simple sensu handler that install checks/events in homeassistant as sensors #
###############################################################################
# Sensu events structure: https://sensuapp.org/docs/1.1/api/events-api.html

################################################################################
# Config
HASS_API_PASSWORD='{{homeassistant_http.api_password}}'
HASS_HOST='http://{{homeassistant_bind_ip}}:{{homeassistant_port}}'
################################################################################

# Extract sensor attributes from sensu event
INPUT=$(< /dev/stdin)
NAME=$(echo "$INPUT" | jq -r .check.name)
STATUS=$(echo "$INPUT" | jq -r .check.status)
# replace newlines with | in the output. Just sending \n doesn't seem to work: there's probably a way to escape \n
# properly, but don't feel like spending another 2hrs on figuring that out :)
OUTPUT=$(echo "$INPUT" | jq -r -j .check.output | tr "\n" "|")
SENSU_EVENT_ID=$(echo "$INPUT" | jq -r .id)
TIMESTAMP=$(echo "$INPUT" | jq -r .timestamp)
SENSOR_TYPE=$(echo "$INPUT" | jq -r .check.homeassistant.sensor_type)
echo "SENSOR TYPE: $SENSOR_TYPE"

 # Determine sensor attributes based on sensu check data
# For name, replace dashboard and periods with underscores

SENSOR_NAME="sensu_${NAME//-/_}"
SENSOR_NAME="${SENSOR_NAME//./_}"

if [ $SENSOR_TYPE == "binary_sensor" ]; then
    if [ $STATUS == "0" ]; then
        SENSOR_STATE="on"
    else
        SENSOR_STATE="off"
    fi
else
    SENSOR_STATE="$OUTPUT"
    # TODO: use jq to parse output. If valid JSON -> merge with payload
    # `echo "$OUTPUT" | jq` will return and >0 exit code if invalid
    # Note that the $OUTPUT has got newlines replaced with | -> we might not want that for this
fi

echo "SENSOR NAME: $SENSOR_NAME"

# Do REST call to Home-assistant to install sensor
# Hass requires the use of double quotes, single quotes will result in the payload being rejected
PAYLOAD='{"state": "'$SENSOR_STATE'", "attributes": {"friendly_name": "'$NAME'", "status": "'$STATUS'", "sensu_event_id": "'$SENSU_EVENT_ID'","output": "'$OUTPUT'",  "source":"sensu", "timestamp": "'$TIMESTAMP'"}}'
echo -n "Making API call to Homeassistant to install sensor $SENSOR_NAME ..."
echo "PAYLOAD: $PAYLOAD"
OUTPUT=$(curl -m 2 -X POST -H "x-ha-access: $HASS_API_PASSWORD"  -H "Content-Type: application/json" -d "$PAYLOAD"  "$HASS_HOST/api/states/$SENSOR_TYPE.$SENSOR_NAME")
echo $OUTPUT
echo -e "DONE"
