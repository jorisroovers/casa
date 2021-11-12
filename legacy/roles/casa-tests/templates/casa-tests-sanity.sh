#!/usr/bin/env bash

echo "****** $(date +'%Y-%m-%d %H:%M:%S %Z') ******"
echo "Running tests..."
echo "-----------------------------------------------------------------------------------------------------------------"
sudo timeout 120 docker run casa-tests pytest -v -rw -s -m sanity --hadashboard-url http://{{casa_ip}}:{{appdaemon_port}} \
                                                   --homeassistant-url http://{{casa_ip}}:{{homeassistant_port}} \
                                                   --homeassistant-token {{homeassistant_api_access_tokens.local_integrations}} \
                                                   --remote-driver-url http://{{casa_ip}}:{{selenium_port}}/wd/hub
test_status_code=$?
echo "-----------------------------------------------------------------------------------------------------------------"
PROM_FILE="{{node_exporter_textfile_exports}}/casa_tests.prom"
echo "Exporting test results to prometheus ($PROM_FILE)..."

cat << EOF > $PROM_FILE
# HELP casa_tests_status Casa tests sanity test run status code
# TYPE casa_tests_status gauge
casa_tests_status{marker="sanity"} $test_status_code
EOF

echo "DONE"
