#!/usr/bin/env bash

alias ?="cat /etc/profile.d/*aliases*"

alias sonos-status="systemctl status {{sonos_http_api_service}}"

function sonos-re(){
    echo "Restarting {{sonos_http_api_service}}..."
    sudo systemctl restart {{sonos_http_api_service}}.service
    echo "Done"
    systemctl status {{sonos_http_api_service}}.service
}

function sonos-start(){
    echo "Starting {{sonos_http_api_service}}..."
    sudo systemctl start {{sonos_http_api_service}}.service
    echo "Done"
    systemctl status {{sonos_http_api_service}}.service
}

function sonos-stop(){
    echo "Stopping {{sonos_http_api_service}}..."
    sudo systemctl stop {{sonos_http_api_service}}.service
    echo "Done"
    systemctl status {{sonos_http_api_service}}.service
}