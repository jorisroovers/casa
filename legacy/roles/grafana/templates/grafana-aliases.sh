#!/usr/bin/env bash

alias ?="cat /etc/profile.d/*aliases*"

alias grafana-status="systemctl status {{grafana_service}}"
alias grafana-logs="sudo grc tail -n 300 -f {{grafana_log_dir}}/grafana.log"
alias grafana-log="grafana-logs"
alias grafana-conf="sudo vim {{grafana_conf_dir}}/grafana.ini"

function grafana-re(){
    echo "Restarting {{grafana_service}}..."
    sudo systemctl restart {{grafana_service}}
    echo "Done"
    systemctl status {{grafana_service}}
}

function grafana-start(){
    echo "Starting {{grafana_service}}..."
    sudo systemctl start {{grafana_service}}
    echo "Done"
    systemctl status {{grafana_service}}
}

function grafana-stop(){
    echo "Stopping {{grafana_service}}..."
    sudo systemctl stop {{grafana_service}}
    echo "Done"
    systemctl status {{grafana_service}}
}