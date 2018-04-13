#!/bin/bash

MERAKI_DEVICE_SERIAL="{{meraki_device_serial}}"
MERAKI_DEVICE_NAME="{{ansible_hostname}}"
MERAKI_API_KEY="{{meraki_api_key}}"

TIMESPAN=$((3600 * 1))
URL="https://dashboard.meraki.com/api/v0/devices/$MERAKI_DEVICE_SERIAL/clients?timespan=$TIMESPAN"

RESPONSE="$(curl -s -L "$URL" -H "x-cisco-meraki-api-key: $MERAKI_API_KEY")"

# prints following output:
# {{ansible_hostname}}.meraki.$hostname.sent.kbytes 15894596 1521830533
# {{ansible_hostname}}.meraki.$hostname.recv.kbytes 5327048 1521830533
# Note that we actually call the recv bytes "sent" and the number of sent bytes "recv", which is a little
# counterintuitive. The reason for this is that the data that we get is from the Meraki AP's perspective.
# That is, the total number of recv bytes for a given device, is the number of bytes the Meraki AP sends to it

for hostname in $(echo "$RESPONSE" | jq -r ".[].dhcpHostname"); do
    HOST_DETAILS=$(echo "$RESPONSE" | jq -r ".[] | select(.dhcpHostname==\"$hostname\")")
    echo -n "{{ansible_hostname}}.meraki.$hostname.sent.kbytes "
    echo "$HOST_DETAILS" | jq -r '"\(.usage.recv | floor) \(now|floor)"'
    echo -n "{{ansible_hostname}}.meraki.$hostname.recv.kbytes "
    echo "$HOST_DETAILS" | jq -r '"\(.usage.sent | floor) \(now|floor)"'
done
