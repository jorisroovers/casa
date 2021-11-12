#!/usr/bin/env bash

alias ?="cat /etc/profile.d/*aliases*"

alias influx-status="systemctl status {{influxdb_service}}"
alias influx-logs="grc tail -n 300 -f /var/log/influxdb/{{influxdb_service}}.log"
alias influx-log="influx-logs"
alias influx-conf="sudo vim {{influxdb_conf_dir}}/influxdb.conf"

function influx-re(){
    echo "Restarting {{influxdb_service}}..."
    sudo systemctl restart {{influxdb_service}}
    echo "Done"
    systemctl status {{influxdb_service}}
}

function influx-start(){
    echo "Starting {{influxdb_service}}..."
    sudo systemctl start {{influxdb_service}}
    echo "Done"
    systemctl status {{influxdb_service}}
}

function influx-stop(){
    echo "Stopping {{influxdb_service}}..."
    sudo systemctl stop {{influxdb_service}}
    echo "Done"
    systemctl status {{influxdb_service}}
}