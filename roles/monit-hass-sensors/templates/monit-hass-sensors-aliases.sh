#!/usr/bin/env bash

alias ?="cat /etc/profile.d/*aliases*"

alias mhs-status="systemctl status {{monit_hass_sensors_service}}"
alias mhs-logs="sudo grc journalctl -n 300 -fu {{monit_hass_sensors_service}}"
alias mhs-log="mhs-logs"

function mhs-re(){
    echo "Restarting {{monit_hass_sensors_service}}..."
    sudo systemctl restart {{monit_hass_sensors_service}}
    echo "Done"
    systemctl status {{monit_hass_sensors_service}}
}

function mhs-start(){
    echo "Starting {{monit_hass_sensors_service}}..."
    sudo systemctl start {{monit_hass_sensors_service}}
    echo "Done"
    systemctl status {{monit_hass_sensors_service}}
}

function mhs-stop(){
    echo "Stopping {{monit_hass_sensors_service}}..."
    sudo systemctl stop {{monit_hass_sensors_service}}
    echo "Done"
    systemctl status {{monit_hass_sensors_service}}
}
