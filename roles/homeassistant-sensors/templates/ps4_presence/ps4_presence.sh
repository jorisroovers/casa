#!/bin/bash

curl -s --max-time 2 {{ps4_host}}:{{ps4_port}}
status=$?
# Need to use double quotes for prometheus to work (it doesn't like single quotes)
echo "ps4_presence{name=\"ps4-presence\", homeassistant=\"yes\"} $status" > {{node_exporter_textfile_exports}}/ps4_presence.prom
