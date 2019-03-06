# TODO
This is a list of things I'm considering to add to casa.

# Needs verification
- Fix Seshat
- Add CPU load to grafana dashboard
- Afvalwijzer sensor in HaDashboard
- Upgrade grafana to 6.x
- Grafana: ansible tasks (under top-level tasks/ to restore grafana datasource)
- HaDash: auto-nav back to homescreen
- avg worked this week
- start/end time work
- PS4 presence sensor
- Fix stats dashboard on grafana
- Add artists playlists to HaDashboard
  - E.g. Select artist, then hit "play button"
- InfluxDB backup restores
- Re-add raspberry pi, incl monitoring
- Sound 5%
- Bathroom motion turn in lights of Home
- Siri maps navigate home

## Fixes
- Fix washing machine
- Fix Roofcam
- Smooth out up/down in desk state sensor

## Incremental Improvements
- PostNL sensor in HaDashboard
- Alexa shopping list sync
- Update HaDash phone dashboards
- Upstairs scenes: packing, working
- Upgrade Homeassistant to latest version

## Aspirational improvements
- Automated Thermostats
- Energy use monitoring: https://www.home-assistant.io/components/utility_meter/
- Light washok
- Light attic incl switch for other lights, but how disable switch
- Standing bulb bureau avond
- Touchpad sensitiviteit
- Siri shortcut ETA home
- Lakens Verschonen sensor
- Lights kelder
- Siris auto backups?

## Other

- Envoy/Nginx proxy for prometheus, webhook
- Location tracking via OwnTracks
   -> This requires a DDNS, which means exposing everything to the web, which has security implications.
- https://home-assistant.io/components/media_player.cast/
- Alexa integration
- Improve roofcam accuracy
- sonos-node-http-api: SSL & auth
- Better messaging in slack (also include lights + custom nest sensors)
- sudo askpass program lastpass
- Smarter office lighting behavior (relax, etc -> don't turn off lights when working)
- Use Flux to change light color in hallway depending on time of day: https://home-assistant.io/components/switch.flux/
- Grafana, discrete panel:
  - Patch: https://github.com/NatelEnergy/grafana-discrete-panel/blob/master/src/module.ts#L194
    To make it so that time is shown not in humanize() but in specified timeframe
- Security:
    - Let's encrypt support
    - TLS everywhere: home-assistant, HADash, Spotify, Sensu, Uchiwa
    - iptable rules for all (just block all and then selectively allow),
        make sure base role wipes all other ip tables rules -> in case I manually set something, this should be undone

- Laptop checks:
  - Spotify playing

- Runkeeper API: https://github.com/mko/runkeeper-js
  -> Stats wrt workouts etc


## Automation Ideas
- When pausing music -> set music preset to NoMusic
- Alerting on e.g. open window: https://home-assistant.io/components/alert/
## Sensor ideas
- Car at home detect sensor based on image recognition
- Door/window sensors
- Custom nest sensors based on python-nest, because current nest sensors in Hass aren't very good
- Nest smoke detector checks integrated with sensu
- Sensu vmstat: https://github.com/sensu-plugins/sensu-plugins-vmstats
- Alarm:
  https://home-assistant.io/components/alarm_control_panel.manual/
  http://appdaemon.readthedocs.io/en/stable/DASHBOARD_CREATION.html#alarm

- Smart meter:
  Use this cable: https://www.sossolutions.nl/slimme-meter-kabel
  https://home-assistant.io/components/sensor.dsmr/

- Weekend Hobby sensor
- Raspberry PI online sensor
- Fix aggregate sensor for homeassistant (google not working)

## Actuator ideas
- PS4Waker

### Homematic Radiotor thermostat
https://www.conrad.nl/nl/homematic-ip-draadloze-radiatorthermostaat-hmip-etrv-2-1406552.html?WT.mc_id=gshop&WT.srch=1&gclid=CjwKCAiArOnUBRBJEiwAX0rG_fbAavfdl8fReKPGIuYmW6GDnaOdXExPkVhENMpaS9t9W8L_VXlm6BoCL-oQAvD_BwE&insert=8J&tid=933477491_46789847735_pla-415594332407_pla-1406552

Seems to work with homeassistant:
https://community.home-assistant.io/t/ccu2-w-homematic-and-homematic-ip-devices/4045/32

Installation instructions
http://www.eq-3.com/Downloads/eq3/downloads_produktkatalog/homematic_ip/bda/HmIP-eTRV-2-UK_UM_web.pdf

Not clear if this will work on our radiators.

## HADashboard
- HADashboard: Volume control
- HADashboard: Custom Nest Cam controls (incl enable-disable support + link to livestream)
- HADashboard: Custom weather widget

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
export HASS_URL="http://$HASS_IP:8123"; export HASS_PASSWORD="$(vault-get ' api_password')";

# Getting  entity picture
curl -s -H "x-ha-access: $HASS_PASSWORD" -H "Content-Type: application/json" $HASS_URL/api/states/camera.hallway | jq -r ".attributes.entity_picture"
# Error log:
curl -s -H "x-ha-access: $HASS_PASSWORD" -H "Content-Type: application/json" $HASS_URL/api/error_log
# Specific entity state:
curl -s -H "x-ha-access: $HASS_PASSWORD" -H "Content-Type: application/json" $HASS_URL/api/states/light.office

# Turn on light
curl -s -H "x-ha-access: $HASS_PASSWORD" -H "Content-Type: application/json" -d '{"entity_id": "light.office"}' $HASS_URL/api/services/light/turn_on

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
pytest -rw -s --hadashboard-url http://$HASS_IP:5050 --homeassistant-url http://$HASS_IP:8123 --homeassistant-password "$(vault-get ' api_password')" tests/
```

# Prometheus
Add basic auth through nginx (or envoy?): https://prometheus.io/docs/guides/basic-auth/

Checks to convert:
- Roofcam alive
- Roofcam water detector
- Sonos Error