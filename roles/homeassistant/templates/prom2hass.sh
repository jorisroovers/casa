#!/bin/bash

################################################################################
# Config
HASS_API_PASSWORD='{{homeassistant_http.api_password}}'
HASS_HOST='http://0.0.0.0:{{homeassistant_port}}'
PROMETHEUS_HOST='http://0.0.0.0:{{prometheus_port}}'
################################################################################

ALERTS=$(curl -s $PROMETHEUS_HOST/api/v1/rules | jq -r .data)
# Flatten out all rules in each group to a single 'rules' array
RULES=$(echo "$ALERTS" |  jq -r '[.groups[].rules[]]')
NUM_RULES=$(echo "$RULES" | jq '. | length')

# For every rule
for i in $(seq 0 $(( $NUM_RULES-1 ))); do
    RULE=$(echo $RULES | jq ".[$i]")
    RULE_NAME=$(echo "$RULE" | jq -r ".name")
    RULE_ALERTS=$(echo "$RULE" | jq -r ".alerts[0].state")

    # Determine sensor attributes based of rules/alert attributes
    SENSOR_NAME="prometheus_${RULE_NAME//-/_}"
    SENSOR_NAME="${SENSOR_NAME//./_}"
    if [ $RULE_ALERTS == "null" ]; then
        SENSOR_STATE="on"
    else
        SENSOR_STATE="off"
    fi
    SENSOR_TYPE="binary_sensor"
    TIMESTAMP=$(date +%s)

    # Do REST call to Home-assistant to install sensor
    # Hass requires the use of double quotes, single quotes will result in the payload being rejected
    PAYLOAD='{"state": "'$SENSOR_STATE'", "attributes": {"friendly_name": "'$SENSOR_NAME'",  "source":"prometheus", "timestamp": "'$TIMESTAMP'"}}'
    echo -n "Making API call to Homeassistant to install sensor $SENSOR_NAME ..."
    echo "PAYLOAD: $PAYLOAD"
    OUTPUT=$(curl -m 2 -X POST -H "x-ha-access: $HASS_API_PASSWORD"  -H "Content-Type: application/json" -d "$PAYLOAD"  "$HASS_HOST/api/states/$SENSOR_TYPE.$SENSOR_NAME")
    echo $OUTPUT
    echo -e "DONE"
done


# Do REST call to Home-assistant to install sensor
# Hass requires the use of double quotes, single quotes will result in the payload being rejected
# PAYLOAD='{"state": "'$SENSOR_STATE'", "attributes": {"friendly_name": "'$NAME'", "status": "'$STATUS'", "sensu_event_id": "'$SENSU_EVENT_ID'","output": "'$OUTPUT'",  "source":"sensu", "timestamp": "'$TIMESTAMP'"}}'
# echo -n "Making API call to Homeassistant to install sensor $SENSOR_NAME ..."
# echo "PAYLOAD: $PAYLOAD"
# # TODO: the line below shows the HA-password in plain-text in the process output, we should fix that
# # Note that this also shows up in "sensu-status" output since this script will be running as a subprocess
# OUTPUT=$(curl -m 2 -X POST -H "x-ha-access: $HASS_API_PASSWORD"  -H "Content-Type: application/json" -d "$PAYLOAD"  "$HASS_HOST/api/states/$SENSOR_TYPE.$SENSOR_NAME")
# echo $OUTPUT
# echo -e "DONE"