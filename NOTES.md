
# Technical notes
Keeping these here mostly for personal reference.

## Samsung TV

TV Model: UE48H6200AW
Using https://github.com/McKael/samtv to control samsung tv.
To Pair:
```sh
./samtvcli --server $SAMSUNGTV_IP pair
# Wait for TV to show pin
./samtvcli --server $SAMSUNGTV_IP pair --pin <pincode>
# CLI will print session id and session key, record these
```

### Older info:
- Samsung smartTV support: https://home-assistant.io/components/media_player.samsungtv/
- https://github.com/Ape/samsungctl
- Open ports: 7676, 8000, 8001, 8080, 8443

Learned about v2 from here: https://github.com/Ape/samsungctl/issues/22

```bash
# TV off
$ curl -I -m 2 http://$SAMSUNGTV_IP:8001/api/v2/
curl: (28) Connection timed out after 2001 milliseconds

# TV on
$ curl -I -m 2 http://$SAMSUNGTV_IP:8001/api/v2/
curl: (7) Failed to connect to $SAMSUNGTV_IP port 8001: Connection refused
```

## InfluxDB:
```bash
export INFLUX_USERNAME="$(vault-get influxdb_admin_user)";export INFLUX_PASSWORD="$(vault-get influxdb_admin_password)"; export INFLUX_HOST="$HASS_IP";

echo "export INFLUX_USERNAME=\"$INFLUX_USERNAME\"; export INFLUX_PASSWORD=\"$INFLUX_PASSWORD\";"
influx -ssl --unsafeSsl -username "$INFLUX_USERNAME" -password "$INFLUX_PASSWORD"
# Examples
show users;
show grants for "<example user>";
use mydatabase;
show series; # recall, influx doesn't have tables, it has timeseries

influx -ssl --unsafeSsl -username "$INFLUX_USERNAME" -password "$INFLUX_PASSWORD" -execute "show databases"


influx -ssl --unsafeSsl -username "$INFLUX_USERNAME" -password "$INFLUX_PASSWORD" -host "$INFLUX_HOST"  -execute "show databases"

```

## python-nest
```bash
source /opt/homeassistant/.venv/bin/activate
export NEST_CLIENT_ID=$(grep "nest:" -A 2 /opt/homeassistant/configuration.yaml  | awk '/client_id/{print $2}')
export NEST_CLIENT_SECRET=$(grep "nest:" -A 2 /opt/homeassistant/configuration.yaml  | awk '/client_secret/{print $2}')
nest --client-id $NEST_CLIENT_ID --client-secret $NEST_CLIENT_SECRET --token-cache /opt/homeassistant/nest.conf --index 0 camera-show
```

## grafana

Using this tool for backups: https://github.com/ysde/grafana-backup-tool

Backup restoration:
```sh
# 1. Get token from http://casa:3001/org/apikeys
# 2. Update grafana_backups_api_token in casa-data
# 3. Run this:
ansible-playbook -i ~/repos/casa-data/inventory/mbp-server home.yml --tags backups,grafana-restore-backup -e "recreate_containers=no grafana_restore_backup=yes"
```
Note that the exported json files (with extension .dashboard) can not just be imported through the grafana UI, you need
to use the same grafana-backup-tool to do the restore, like so:

```bash
cd /tmp; git clone https://github.com/ysde/grafana-backup-tool.git
# 1. Get token from http://casa:3001/org/apikeys
# 2. Update grafana_backups_api_token in casa-data
export GRAFANA_URL="http://casa:3001"; export GRAFANA_TOKEN="$(vault-get grafana_backups_api_token)";
python grafana-backup-tool/createDashboard.py ~/Downloads/dashboards/Overview.dashboard
ansible-playbook -i ~/repos/casa-data/inventory/mbp-server home.yml --tags backups
```

# Miscellaneous notes

## SCP

scp -P 2222 -i ~/repos/casa/.vagrant/machines/home/virtualbox/private_key ubuntu@127.0.0.1:/home/ubuntu/redis.conf .

## Hass APIs
```bash
export HASS_URL="http://0.0.0.0:8123"; export HASS_PASSWORD="$(awk '/api_password: /{print $2}'  /opt/homeassistant/configuration.yaml)"

export HASS_URL="http://$HASS_IP:8123"; export HASS_PASSWORD="$(vault-get ' api_password')"; export HASS_TOKEN="$(vault-get 'local_integrations')";

# Getting  entity picture
curl -s -H "Authorization: Bearer $HASS_TOKEN" -H "Content-Type: application/json" $HASS_URL/api/states/camera.hallway | jq -r ".attributes.entity_picture"
# Error log:
curl -s -H "Authorization: Bearer $HASS_TOKEN" -H "Content-Type: application/json" $HASS_URL/api/error_log

# Specific entity state:
curl -s -H "Authorization: Bearer $HASS_TOKEN" -H "Content-Type: application/json" $HASS_URL/api/states/light.office


# Turn on light
curl -s -H "Authorization: Bearer $HASS_TOKEN" -H "Content-Type: application/json" -d '{"entity_id": "light.office"}' $HASS_URL/api/services/light/turn_on

```

## seshat

```sh
export INFLUXDB_BIND_IP="0.0.0.0"
export INFLUXDB_DB=""
export INFLUXDB_USERNAME=""
export INFLUXDB_PASSWORD=""


/usr/bin/node /opt/sensu/checks/seshat/dist/duration.js -k --measurement sensor.desk_state --state up --write-duration --host $INFLUXDB_BIND_IP --database $INFLUXDB_DB  --username $INFLUXDB_USERNAME  --password $INFLUXDB_PASSWORD
```
## Sensu
Location of binary check scripts:
```
/opt/sensu/embedded/bin/check-ping.rb --help
```

Logs:
/var/log/sensu/*

Important note wrt sensu checks:
From https://sensuapp.org/docs/1.1/guides/getting-started/intro-to-checks.html#create-the-check-definition-for-cpu-metrics

By default, Sensu checks with an exit status code of 0 (for OK) do not create events unless they indicate a change in
state from a non-zero status to a zero status (i.e. resulting in a resolve action). Metric collection checks will output
metric data regardless of the check exit status code, however, they usually exit 0. To ensure events are always created
for a metric collection check, the check type of metric is used.

Things I don't like about sensu:
 - For standard checks, not all checks cause events, only if something goes wrong (see above)
 - No remediation included by default - hard to do event with plugins

## Lights
Color:

Tradfri white spectrum lamps support between 2200 (warm)  and 4000 (cold) Kelvin.
That *should* translate to 0-250 mireds (color_temp in hass), but that doesn't seem to be working
http://www.leefilters.com/lighting/mired-shift-calculator.html

Home-assistant does not allow you to change attributes (like kelvin/brightness) on a group of lights at a time yet
Even if they are exposed by Tradfri/Hue as a single light.
https://community.home-assistant.io/t/grouped-light-control/1034/49

### Tradfri

https://github.com/home-assistant/home-assistant/pull/19288/commits/871346535f55f42b4f8fa46ebab4d4255678b795


2019-04-29 23:32:53 WARNING (MainThread) [homeassistant.components.tradfri.sensor] Observation failed for TRADFRI remote control
Traceback (most recent call last):
  File "/usr/local/lib/python3.7/site-packages/pytradfri/api/aiocoap_api.py", line 95, in _get_response
    r = await pr.response
  File "/usr/local/lib/python3.7/site-packages/aiocoap/protocol.py", line 816, in _run_outer
    yield from cls._run(app_request, response, weak_observation, protocol, log, exchange_monitor_factory)
  File "/usr/local/lib/python3.7/site-packages/aiocoap/protocol.py", line 865, in _run
    blockresponse = yield from blockrequest.response
aiocoap.error.RequestTimedOut
2019-04-29 23:32:53 ERROR (MainThread) [homeassistant.core] Error doing job: Task exception was never retrieved
Traceback (most recent call last):
  File "/usr/local/lib/python3.7/site-packages/pytradfri/api/aiocoap_api.py", line 155, in request
    result = await self._execute(api_commands)
  File "/usr/local/lib/python3.7/site-packages/pytradfri/api/aiocoap_api.py", line 114, in _execute
    await self._observe(api_command)
  File "/usr/local/lib/python3.7/site-packages/pytradfri/api/aiocoap_api.py", line 172, in _observe
    pr, r = await self._get_response(msg)
  File "/usr/local/lib/python3.7/site-packages/pytradfri/api/aiocoap_api.py", line 95, in _get_response
    r = await pr.response
  File "/usr/local/lib/python3.7/site-packages/aiocoap/protocol.py", line 816, in _run_outer
    yield from cls._run(app_request, response, weak_observation, protocol, log, exchange_monitor_factory)
  File "/usr/local/lib/python3.7/site-packages/aiocoap/protocol.py", line 865, in _run
    blockresponse = yield from blockrequest.response
  File "/usr/local/lib/python3.7/site-packages/aiocoap/protocol.py", line 740, in send_request
    self.protocol.send_message(request, self._exchange_monitor_factory(request))
  File "/usr/local/lib/python3.7/site-packages/aiocoap/protocol.py", line 450, in send_message
    self._send_initially(message, exchange_monitor)
  File "/usr/local/lib/python3.7/site-packages/aiocoap/protocol.py", line 458, in _send_initially
    self._add_exchange(message, exchange_monitor)
  File "/usr/local/lib/python3.7/site-packages/aiocoap/protocol.py", line 269, in _add_exchange
    self._active_exchanges[key] = (exchange_monitor, next_retransmission)
TypeError: 'NoneType' object does not support item assignment
2019-04-29 23:32:54 INFO (SyncWorker_9) [root] Sending control command: KEY
2019-04-29 23:32:56 ERROR (MainThread) [homeassistant.core] Error doing job: Exception in callback <function Context._schedule_retransmit.<locals>.retr at 0x7fd603c4cc80>
Traceback (most recent call last):
  File "uvloop/cbhandles.pyx", line 245, in uvloop.loop.TimerHandle._run
  File "/usr/local/lib/python3.7/site-packages/aiocoap/protocol.py", line 330, in retr
    self._retransmit(message, timeout, retransmission_counter)
  File "/usr/local/lib/python3.7/site-packages/aiocoap/protocol.py", line 337, in _retransmit
    exchange_monitor, next_retransmission = self._active_exchanges.pop(key)
AttributeError: 'NoneType' object has no attribute 'pop'

## Extra open ports

6379 -> Redis

1400 -> Homeassistant SoCo API (Sonos)
https://github.com/home-assistant/home-assistant/blob/44e4f8d1bad624f8d27dfda7230f0a0a2409a404/homeassistant/components/media_player/sonos.py#L557

631 -> IPP Port (Internet Printing Protocol)
TODO: Disable/remove CUPS

8088 -> InfluxDB

3030, 3031 -> Sensu-client (Ruby)

5355 -> systemd resolve:
https://askubuntu.com/questions/907246/how-to-disable-systemd-resolved-in-ubuntu


IPv6 traffic?


## Sonos-http-api
When Sonos playbar is streaming from tv the /TV Room/state call returns the following.
When turning off the TV, this state stays the same, except for the elapsedTime being reset to 0. This does
also happen at different occasions (e.g. when switching HDMI inputs, etc), so this doesn't seem to be a reliable
way of determining whether the TV is on or off.

```
curl -s "http://192.168.1.121:5005/TV%20Room/state" | jq
```

```json
{
  "volume": 24,
  "mute": false,
  "equalizer": {
    "bass": 0,
    "treble": 0,
    "loudness": true,
    "speechEnhancement": false,
    "nightMode": false
  },
  "currentTrack": {
    "duration": 0,
    "uri": "x-sonos-htastream:RINCON_B8E93742407C01400:spdif",
    "type": "line_in",
    "stationName": ""
  },
  "nextTrack": {
    "artist": "",
    "title": "",
    "album": "",
    "albumArtUri": "",
    "duration": 0,
    "uri": ""
  },
  "trackNo": 1,
  "elapsedTime": 74,
  "elapsedTimeFormatted": "00:01:14",
  "playbackState": "PLAYING",
  "playMode": {
    "repeat": "none",
    "shuffle": false,
    "crossfade": false
  }
}
```

# Tests

```bash
source activate .venv36 # conda env
cd tests  # important to be inside the tests directory!
pytest -rw -s --hadashboard-url http://$HASS_IP:5050 --homeassistant-url http://$HASS_IP:8123 --homeassistant-token "$(vault-get 'local_integrations')" tests/

```

# Prometheus
Add basic auth through nginx (or envoy?): https://prometheus.io/docs/guides/basic-auth/

Checks to convert:
- Roofcam alive
- Roofcam water detector
- Sonos Error


