#!/bin/bash

# config
UDM_HOST=$(cat secrets.yaml | awk '/udm_pro_host/{print $2}')
UDM_BASE_URL="https://$UDM_HOST:443"
UDM_USERNAME=$(cat secrets.yaml | awk '/udm_pro_username/{print $2}')
UDM_PASSWORD=$(cat secrets.yaml | awk '/udm_pro_password/{print $2}')

# Authenticate
# This line sets cookie in /tmp/cookie.txt and captures the x-csrf-token header
# Note the use of `-o /dev/null -D -` to send headers to stdout
CSRF_TOKEN=$(curl -s -k -X POST -c /tmp/cookie.txt --data '{"username":"'$UDM_USERNAME'", "password": "'$UDM_PASSWORD'"}' -H "Content-Type: application/json" -o /dev/null -D - $UDM_BASE_URL/api/auth/login | awk -F ': ' '/x-csrf-token/{print $2}')
# Fetch Data
DATA=$(curl -s -k -X POST -b /tmp/cookie.txt -H "x-csrf-token: $CSRF_TOKEN"  -H "Content-Type: application/json" -d '{"cmd":"list-backups"}' $UDM_BASE_URL/proxy/network/api/s/default/cmd/backup)

# Extract last backup timestamp (=microsec accuracy)
NANO_TS=$(echo "$DATA" | jq -r ".data[].time"  | sort | tail -1)

# Divide by 1000 to get unix timestamp
echo $(( $NANO_TS / 1000 ))
