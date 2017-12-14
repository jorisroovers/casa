#!/usr/bin/env bash

alias ?="cat /etc/profile.d/*aliases*"

alias ha-status="systemctl status {{homeassistant_service}}"
alias ha-logs="grc tail -n 300 -f {{homeassistant_dir}}/home-assistant.log"
alias ha-log="ha-logs"
alias ha-conf="vim {{homeassistant_dir}}"


function ha-re(){
    echo "Restarting homeassistant..."
    sudo systemctl restart {{homeassistant_service}}
    echo "Done"
    systemctl status {{homeassistant_service}}
}

function ha-start(){
    echo "Starting homeassistant..."
    sudo systemctl start {{homeassistant_service}}
    echo "Done"
    systemctl status {{homeassistant_service}}
}

function ha-stop(){
    echo "Stopping homeassistant..."
    sudo systemctl stop {{homeassistant_service}}
    echo "Done"
    systemctl status {{homeassistant_service}}
}