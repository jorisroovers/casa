#!/usr/bin/env bash

alias ?="cat /etc/profile.d/*aliases*"

alias roofcam-status="systemctl status {{roofcam_service}}"
alias roofcam-logs="sudo grc journalctl -n 300 -fu {{roofcam_service}}"
alias roofcam-log="roofcam-logs"

function roofcam-re(){
    echo "Restarting {{roofcam_service}}..."
    sudo systemctl restart {{roofcam_service}}
    echo "Done"
    systemctl status {{roofcam_service}}
}

function roofcam-start(){
    echo "Starting {{roofcam_service}}..."
    sudo systemctl start {{roofcam_service}}
    echo "Done"
    systemctl status {{roofcam_service}}
}

function roofcam-stop(){
    echo "Stopping {{roofcam_service}}..."
    sudo systemctl stop {{roofcam_service}}
    echo "Done"
    systemctl status {{roofcam_service}}
}
