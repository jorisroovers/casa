#!/usr/bin/env bash

alias ?="cat /etc/profile.d/*aliases*"

alias sensu-status="systemctl status {{sensu_server_service}}"
alias sensu-logs="grc tail -n 300 -f /var/log/sensu/{{sensu_server_service}}.log"
alias sensu-log="sensu-logs"
alias sensu-conf="sudo vim {{sensu_conf_dir}}"

function sensu-re(){
    echo "Restarting {{sensu_server_service}}..."
    sudo systemctl restart {{sensu_server_service}}
    echo "Done"
    systemctl status {{sensu_server_service}}
}

function sensu-start(){
    echo "Starting {{sensu_server_service}}..."
    sudo systemctl start {{sensu_server_service}}
    echo "Done"
    systemctl status {{sensu_server_service}}
}

function sensu-stop(){
    echo "Stopping {{sensu_server_service}}..."
    sudo systemctl stop {{sensu_server_service}}
    echo "Done"
    systemctl status {{sensu_server_service}}
}