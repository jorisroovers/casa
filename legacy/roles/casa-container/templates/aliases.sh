#!/usr/bin/env bash

alias ?="cat /etc/profile.d/*aliases*"

alias {{alias_shorthand}}-status='sudo docker ps -f "name={{container_name}}"'
alias {{alias_shorthand}}-logs="sudo docker logs --tail 300 -f {{container_name}}"
alias {{alias_shorthand}}-log="{{alias_shorthand}}-logs"

function {{alias_shorthand}}-re(){
    echo "Restarting {{container_name}}..."
    sudo docker restart {{container_name}}
    echo "Done"
    sudo docker ps -f "name={{container_name}}"
}

function {{alias_shorthand}}-kill(){
    echo "Killing {{container_name}}..."
    sudo docker kill {{container_name}}
    echo "Done"
    sudo docker ps -f "name={{container_name}}"
}

function {{alias_shorthand}}-start(){
    echo "Starting {{container_name}}..."
    sudo docker start {{container_name}}
    echo "Done"
    sudo docker ps -f "name={{container_name}}"
}

function {{alias_shorthand}}-stop(){
    echo "Stopping {{container_name}}..."
    sudo docker stop {{container_name}}
    echo "Done"
    sudo docker ps -f "name={{container_name}}"
}