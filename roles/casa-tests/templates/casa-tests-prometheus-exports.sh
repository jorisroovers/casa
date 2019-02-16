#!/usr/bin/env bash

echo "Running tests..."
echo "-----------------------------------------------------------------------------------------------------------------"
docker run casa-tests pytest -rw -s --hadashboard-url http://{{casa_ip}}:{{appdaemon_port}} \
                                    --homeassistant-url http://{{casa_ip}}:{{homeassistant_port}} \
                                    --homeassistant-password $(awk '/api_password/{print $2}' /opt/homeassistant/configuration.yaml) \
                                    --remote-driver-url http://{{casa_ip}}:{{selenium_port}}/wd/hub \
                                    test_homeassistant.py::test_light_naming_convention
test_results=$?
echo "-----------------------------------------------------------------------------------------------------------------"

echo "DONE"
