#!/bin/bash

status=$(curl -s --max-time 2 {{ps4_host}}:{{ps4_port}} && echo "1" || echo "0")

# Need to use double quotes for prometheus to work (it doesn't like single quotes)
echo "ps4_presence{name=\"ps4-presence\", homeassistant=\"yes\", homeassistant_sensor_type=\"binary_sensor\"} $status" > {{node_exporter_textfile_exports}}/ps4_presence.prom
