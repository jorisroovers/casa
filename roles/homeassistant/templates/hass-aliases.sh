#!/usr/bin/env bash

alias ?="cat /etc/profile.d/hass-aliases.sh"

alias status="systemctl status homeassistant@{{ansible_ssh_user}}.service"
alias re="systemctl restart homeassistant@{{ansible_ssh_user}}.service"
