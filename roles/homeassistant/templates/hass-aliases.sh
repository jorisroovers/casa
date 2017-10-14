#!/usr/bin/env bash

alias ?="cat /etc/profile.d/*aliases*"

alias ha-status="systemctl status homeassistant@{{homeassistant_user}}.service"
alias ha-logs="grc tail -n 300 -f {{homeassistant_dir}}/home-assistant.log"
alias ha-log="ha-logs"

function ha-re(){
    echo "Restarting homeassistant..."
    sudo systemctl restart homeassistant@{{homeassistant_user}}.service
    echo "Done"
    systemctl status homeassistant@{{homeassistant_user}}.service
}

function ha-start(){
    echo "Starting homeassistant..."
    sudo systemctl start homeassistant@{{homeassistant_user}}.service
    echo "Done"
    systemctl status homeassistant@{{homeassistant_user}}.service
}

function ha-stop(){
    echo "Stopping homeassistant..."
    sudo systemctl stop homeassistant@{{homeassistant_user}}.service
    echo "Done"
    systemctl status homeassistant@{{homeassistant_user}}.service
}