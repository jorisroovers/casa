#!/usr/bin/env bash

alias ?="cat /etc/profile.d/*aliases*"

alias {{service_shorthand}}-status="systemctl status {{service_name}}"
alias {{service_shorthand}}-logs="sudo grc journalctl -n 300 -fu {{service_name}}"
alias {{service_shorthand}}-log="{{service_shorthand}}-logs"

# Don't use 'function' keyword or dashes in function names below
# This causes issues on some distros, ran into this on Raspbian.

alias {{service_shorthand}}-re="{{service_shorthand_clean}}_re"
alias {{service_shorthand}}-start="{{service_shorthand_clean}}_start"
alias {{service_shorthand}}-stop="{{service_shorthand_clean}}_stop"

{{service_shorthand_clean}}_re(){
    echo "Restarting {{service_name}}..."
    sudo systemctl restart {{service_name}}
    echo "Done"
    systemctl status {{service_name}}
}

{{service_shorthand_clean}}_start(){
    echo "Starting {{service_name}}..."
    sudo systemctl start {{service_name}}
    echo "Done"
    systemctl status {{service_name}}
}

{{service_shorthand_clean}}_stop(){
    echo "Stopping {{service_name}}..."
    sudo systemctl stop {{service_name}}
    echo "Done"
    systemctl status {{service_name}}
}
