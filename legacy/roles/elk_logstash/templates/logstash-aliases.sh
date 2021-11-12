#!/usr/bin/env bash

alias ?="cat /etc/profile.d/*aliases*"

alias logstash-status="systemctl status {{logstash_service}}"
alias logstash-logs="grc tail -n 300 -f /var/log/logstash/logstash-plain.log"
alias logstash-log="logstash-logs"
alias logstash-conf="sudo vim {{logstash_pipeline_conf_dir}}/http-to-file.conf"


function logstash-re(){
    echo "Restarting {{logstash_service}}..."
    sudo systemctl restart {{logstash_service}}
    echo "Done"
    systemctl status {{logstash_service}}
}

function logstash-start(){
    echo "Starting {{logstash_service}}..."
    sudo systemctl start {{logstash_service}}
    echo "Done"
    systemctl status {{logstash_service}}
}

function logstash-stop(){
    echo "Stopping {{logstash_service}}..."
    sudo systemctl stop {{logstash_service}}
    echo "Done"
    systemctl status {{logstash_service}}
}