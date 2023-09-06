#!/bin/bash

# config
UDM_HOST=$(cat secrets.yaml | awk '/udm_pro_host/{print $2}')
UDM_BASE_URL="https://$UDM_HOST:443"
UDM_USERNAME=$(cat secrets.yaml | awk '/udm_pro_username/{print $2}')
UDM_PASSWORD=$(cat secrets.yaml | awk '/udm_pro_password/{print $2}')

# Authenticate and fetch data
curl -s -k -X POST --data '{"username":"'$UDM_USERNAME'", "password": "'$UDM_PASSWORD'"}' -H "Content-Type: application/json" -c /tmp/cookie.txt $UDM_BASE_URL/api/auth/login > /dev/null
DATA=$(curl -s -k -X GET -b /tmp/cookie.txt $UDM_BASE_URL/proxy/network/api/s/default/stat/device)

# echo "$DATA" | jq . >> foo.txt

# Extract data for UDM Pro
UDM_PRO_DATA=$(echo "$DATA" | jq '.data[] | select(.model == "UDMPRO")')
UDM_PRO_TEMP=$(echo "$UDM_PRO_DATA" | jq -j '.temperatures[] | select(.name == "CPU").value')
UDM_PRO_CPU=$(echo "$UDM_PRO_DATA" | jq -r -j '."system-stats".cpu')
UDM_PRO_MEM=$(echo "$UDM_PRO_DATA" | jq -r -j '."system-stats".mem')
UDM_PRO_UPTIME=$(echo "$UDM_PRO_DATA" | jq -r -j '."system-stats".uptime')

# Extract data for USW-24-POE
USW_24_POE_DATA=$(echo "$DATA" | jq '.data[] | select(.model == "USL24P")')
USW_24_POE_CPU=$(echo "$USW_24_POE_DATA" | jq -r -j '."system-stats".cpu')
USW_24_POE_MEM=$(echo "$USW_24_POE_DATA" | jq -r -j '."system-stats".mem')
USW_24_POE_UPTIME=$(echo "$USW_24_POE_DATA" | jq -r -j '."system-stats".uptime')

echo "$UDM_PRO_TEMP|$UDM_PRO_CPU|$UDM_PRO_MEM|$UDM_PRO_UPTIME|$USW_24_POE_CPU|$USW_24_POE_MEM|$USW_24_POE_UPTIME"