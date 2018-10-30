#!/usr/bin/env bash

alias ?="cat /etc/profile.d/*aliases*"

alias {{service_shorthand}}-status="systemctl status {{service_name}}"
alias {{service_shorthand}}-logs="sudo grc journalctl -n 300 -fu {{service_name}}"
alias {{service_shorthand}}-log="{{service_shorthand}}-logs"

function {{service_shorthand}}-re(){
    echo "Restarting {{service_name}}..."
    sudo systemctl restart {{service_name}}
    echo "Done"
    systemctl status {{service_name}}
}

function {{service_shorthand}}-start(){
    echo "Starting {{service_name}}..."
    sudo systemctl start {{service_name}}
    echo "Done"
    systemctl status {{service_name}}
}

function {{service_shorthand}}-stop(){
    echo "Stopping {{service_name}}..."
    sudo systemctl stop {{service_name}}
    echo "Done"
    systemctl status {{service_name}}
}
