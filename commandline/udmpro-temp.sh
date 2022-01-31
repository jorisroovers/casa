#!/bin/bash

UDM_HOST=$(cat secrets.yaml | awk '/udm_pro_host/{print $2}')
UDM_BASE_URL="https://$UDM_HOST:443"
UDM_USERNAME=$(cat secrets.yaml | awk '/udm_pro_username/{print $2}')
UDM_PASSWORD=$(cat secrets.yaml | awk '/udm_pro_password/{print $2}')

curl -s -k -X POST --data '{"username":"'$UDM_USERNAME'", "password": "'$UDM_PASSWORD'"}' -H "Content-Type: application/json" -c /tmp/cookie.txt $UDM_BASE_URL/api/auth/login > /dev/null
DATA=$(curl -s -k -X GET -b /tmp/cookie.txt $UDM_BASE_URL/proxy/network/api/s/default/stat/device)
echo "$DATA" | jq '.data[] | select(.model == "UDMPRO").temperatures[] | select(.name == "CPU").value'