#!/usr/bin/env bash

alias ?="cat /etc/profile.d/*aliases*"

alias ad-status="systemctl status appdaemon@{{appdaemon_user}}.service"
alias ad-logs="sudo journalctl -fu appdaemon@joris.service"
alias ad-log="ha-logs"

function ad-re(){
    echo "Restarting appdaemon..."
    sudo systemctl restart appdaemon@{{appdaemon_user}}.service
    echo "Done"
    systemctl status appdaemon@{{appdaemon_user}}.service
}

function ad-start(){
    echo "Starting appdaemon..."
    sudo systemctl start appdaemon@{{appdaemon_user}}.service
    echo "Done"
    systemctl status appdaemon@{{appdaemon_user}}.service
}

function ad-stop(){
    echo "Stopping appdaemon..."
    sudo systemctl stop appdaemon@{{appdaemon_user}}.service
    echo "Done"
    systemctl status appdaemon@{{appdaemon_user}}.service
}
