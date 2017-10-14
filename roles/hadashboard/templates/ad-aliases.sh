#!/usr/bin/env bash

alias ?="cat /etc/profile.d/*aliases*"

alias ad-status="systemctl status {{appdaemon_service}}"
alias ad-logs="sudo grc journalctl -n 300 -fu {{appdaemon_service}}"
alias ad-log="ad-logs"

function ad-re(){
    echo "Restarting appdaemon..."
    sudo systemctl restart {{appdaemon_service}}
    echo "Done"
    systemctl status {{appdaemon_service}}
}

function ad-start(){
    echo "Starting appdaemon..."
    sudo systemctl start {{appdaemon_service}}
    echo "Done"
    systemctl status {{appdaemon_service}}
}

function ad-stop(){
    echo "Stopping appdaemon..."
    sudo systemctl stop {{appdaemon_service}}
    echo "Done"
    systemctl status {{appdaemon_service}}
}
