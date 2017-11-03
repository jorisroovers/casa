#!/bin/bash
######################################################################################################
# Simple script that fetches checks from monit and installs them as binary sensors in Home-assistant #
######################################################################################################

HASS_API_PASSWORD='{{homeassistant_http.api_password}}'
MONIT_USERNAME='{{monit_http_username}}'
MONIT_PASSWORD='{{monit_http_password}}'
MONIT_HOST='{{monit_hass_sensors_monit_url}}'
HASS_HOST='{{monit_hass_sensors_ha_url}}'
SLEEP_INTERVAL="10"

##################################################
GREEN="\e[32m"
NO_COLOR="\e[0m"
##################################################

# Using a while loop with sleep timer instead of cron job because cron does not do sub-minute intervals
while true ; do

    echo "Fetching services from Monit ($HASS_HOST)..."
    # Fetches services XML from monit
    SERVICES=$(curl -m 1 -su "$MONIT_USERNAME:$MONIT_PASSWORD" "$MONIT_HOST/_status?format=xml" | xml2json | jq '.monit.service')
    NUM_SERVICES=$(echo "$SERVICES" | jq '. | length')

    echo "Parsing data..."
    echo "-----------------------------------"

    AGGREGATE_SENSOR_STATE="on"

    for i in $(seq 0 $(( $NUM_SERVICES-1 ))); do
        # Extract fields from monit check data
        SERVICE=$(echo $SERVICES | jq ".[$i]")
        NAME=$(echo $SERVICE | jq -r '.name')
        STATUS=$(echo $SERVICE | jq -r '.status')
        TYPE=$(echo $SERVICE | jq -r '.type')
        COLLECTED=$(echo $SERVICE | jq -r '.collected_sec')

        # Determine sensor attributes based on monit check data
        # For name, replace dashboard and periods with underscores
        SENSOR_NAME="monit_${NAME//-/_}"
        SENSOR_NAME="${SENSOR_NAME//./_}"
        
        if [ $STATUS == "0" ]; then
            SENSOR_STATE="on"
        else
            SENSOR_STATE="off"
            AGGREGATE_SENSOR_STATE="off"
        fi

        # Debugging info
        
        echo "     Name: $NAME (sensor: $SENSOR_NAME)"
        echo "     Type: $TYPE"
        echo "   Status: $STATUS (sensor state: $SENSOR_STATE)"
        echo "Collected: $COLLECTED"

        # Do REST call to Home-assistant to install sensor
        # Hass requires the use of double quotes, single quotes will result in the payload being rejected
        PAYLOAD='{"state": "'$SENSOR_STATE'", "attributes": {"friendly_name": "'$NAME'", "source":"monit", "type": "'$TYPE'", "collected": "'$COLLECTED'"}}'
        echo -n "Making API call to Homeassistant to install binary sensor..."
        OUTPUT=$(curl -s -m 2 -X POST -H "x-ha-access: $HASS_API_PASSWORD"  -H "Content-Type: application/json" -d "$PAYLOAD"  "$HASS_HOST/api/states/binary_sensor.$SENSOR_NAME")
        echo -e "${GREEN}DONE${NO_COLOR}"
        echo "-----------------------------------"
    done

    echo -n "Installing aggregate monit sensor..."
    PAYLOAD='{"state": "'$AGGREGATE_SENSOR_STATE'", "attributes": {"friendly_name": "Monit Aggregate Sensor", "source":"monit", "type": "aggregate", "collected": "'$(date +%s)'"}}'
    OUTPUT=$(curl -s -m 2 -X POST -H "x-ha-access: $HASS_API_PASSWORD"  -H "Content-Type: application/json" -d "$PAYLOAD"  "$HASS_HOST/api/states/binary_sensor.monit_aggregate")
    echo -e "${GREEN}DONE${NO_COLOR}"
    
    echo "-----------------------------------"
    echo -e "${GREEN}ALL DONE${NO_COLOR}"
    sleep $SLEEP_INTERVAL
done