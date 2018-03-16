# casa
Set of ansible playbooks that I use to maintain my [homeassistant](home-assistant.io)-based home automation stack.

![HADashboard Preview](docs/images/Home.png)

I maintain this purely for fun (often favoring speed and exploration over quality) and really only with my own use-cases
in mind, so use at your own risk! I don't expect the actual code to work for anyone but me, so please consider this as
more as a reference rather than a plug-and-play solution.

You might see a reference here and there to ```casa-data```: this is a private repo I maintain that contains the actual
data relevant to my home (usernames, passwords, secrets, IP addresses, etc). The roles and playbooks in this repo all
use dummy defaults.

Also, since my family's mother tongue is Dutch, you'll see some Dutch language used here and there
(mostly in the user-facing parts).
# Setup
## Hardware
I run the whole automation stack on a 2011 Macbook Pro running Ubuntu 17.10.

Here's a list of home-automation gear I use that is integrated with casa:
- Sonos play 5, play 1, play base
- Philips Hue light bulbs
- Ikea Tradfri light bulbs (and movement sensors, remote controls)
- iPad mini control planels
- Chromecast
- Nest Cam
- Nest Thermostat
- Nest Protect smoke detectors
- TP link HS100 and HS110 Power Switches
- A simple custom-build Arduino sensor for measure the current height of my standing desk

Other gear I have that is currently not (yet) integrated in the setup:
- AppleTV (there are some issues with pyatv turning on the TV randomly)
- Elgato Eve Window sensor
- Elgato Eve Power plug
- Amazon Echo dot

## Software Stack

The best way to get a quick overview of the software stack is to look at roles directory

Ubuntu 17.10
[Homeassistant](https://home-assistant.io/)
[HADashboard](http://appdaemon.readthedocs.io/en/stable/DASHBOARD_INSTALL.html)
node-sonos-http-api
slack

# Getting Started

I'm currently using Ansible 2.4.2 and am using some Ansible 2.4 specific features in the playbooks, so that's the
version of ansible you'll need :)

### DEV
Development should be done locally in Vagrant.
```bash
vagrant up
ansible-playbook home.yml -i inventory/vagrant
# roofcam only
ansible-playbook home.yml -i inventory/vagrant --tags roofcam
# using production data
ansible-playbook home.yml -i  ~/repos/casa-data/inventory/vagrant
```
### PROD

This won't be useful to anyone else but me :-)

```bash
ansible-playbook --ask-pass --ask-sudo-pass home.yml -i ~/repos/casa-data/inventory/mbp-server
# roofcam only
ansible-playbook --ask-pass --ask-sudo-pass home.yml -i ~/repos/casa-data/inventory/mbp-server --tags roofcam
```


# TODO
- Groups: https://home-assistant.io/components/group/

- Location tracking via OwnTracks
   -> This requires a DDNS, which means exposing everything to the web, which has security implications.
- https://home-assistant.io/components/media_player.cast/
- Alexa support
- Calling "homeassistant/reload_core_config" one config reload instead of doing a HA restart
- Force state update on Nest after changing state through python-nest command
- Improve roofcam accuracy
- sonos-node-http-api: SSL & auth
- Better messaging in slack (also include lights + custom nest sensors)
- Sensu: influxdb checks
- sudo askpass program lastpass
- limit speedtest.net CPU cycles using cgroups
- Smarter office lighting behavior (relax, etc -> don't turn off lights when working)
- HADashboard automatically go back to homescreen when no activity
- Use Flux to change light color in hallway depending on time of day: https://home-assistant.io/components/switch.flux/
- Upstairs scenes: packing, working

- Security:
    - Let's encrypt support
    - TLS everywhere: home-assistant, HADash, Spotify, Sensu, Uchiwa
    - iptable rules for all (just block all and then selectively allow),
        make sure base role wipes all other ip tables rules -> in case I manually set something, this should be undone

- Laptop checks:
  - Spotify playing

## Automation Ideas
- When pausing music -> set music preset to NoMusic

## Sensor ideas
- Gaming sensor based on PS4 & TV Awake
- Watching TV sensor based on TV Awake
- Roofcam sensor (refactor monit-hass-sensors to be more generic)
- Car at home detect sensor based on image recognition
- Door/window sensors
- Custom nest sensors based on python-nest, because current nest sensors in Hass aren't very good
- Nest smoke detector checks integrated with sensu
- Power switch with usage sensor for washing machine to determine whether it's on or not
  TP-LINK HS110 should be able to support this in hass: https://github.com/home-assistant/home-assistant/blob/master/homeassistant/components/switch/tplink.py#L105-L120

- Sensu vmstat: https://github.com/sensu-plugins/sensu-plugins-vmstats
- Alarm:
  https://home-assistant.io/components/alarm_control_panel.manual/
  http://appdaemon.readthedocs.io/en/stable/DASHBOARD_CREATION.html#alarm

- Smart meter:
  Use this cable: https://www.sossolutions.nl/slimme-meter-kabel
  https://home-assistant.io/components/sensor.dsmr/

## Actuator ideas

- Mirror bathroom heating:
https://www.vloerverwarmingstore.nl/producten/87-1-overige+oplossingen/89-1-spiegelverwarming/p-239-e-heat+spiegelverwarming+folie?selected=622
- Auto turn on mirror light when bathroom lights turn on using tp-link
  (only when house not sleeping)

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
- HADashboard: enlarge camera view on click (not so hard using custom JS)
- HADashboard: Custom weather widget
- Automatically go back to Home page after idle for x sec on a given page

# Technical notes
Keeping these here mostly for personal reference.

## Samsung TV

- Samsung smartTV support: https://home-assistant.io/components/media_player.samsungtv/
    - Model Code: UE48H6200AW
    - Open ports:
    Open TCP Port: 	7676   		imqbrokerd
	 Open TCP Port: 	8000   		irdmi
	 Open TCP Port: 	8001   		vcom-tunnel
	 Open TCP Port: 	8080   		http-alt
	 Open TCP Port: 	8443   		pcsync
    - https://github.com/Ape/samsungctl


Learned about v2 from here: https://github.com/Ape/samsungctl/issues/22

http://$SAMSUNGTV_IP:8001/api/v2/

```bash
# TV off
$ curl -I -m 2 http://$SAMSUNGTV_IP:8001/api/v2/
curl: (28) Connection timed out after 2001 milliseconds

# TV on
$ curl -I -m 2 http://$SAMSUNGTV_IP:8001/api/v2/
curl: (7) Failed to connect to $SAMSUNGTV_IP port 8001: Connection refused
```


## InfluxDB:
```
export INFLUX_USERNAME="$(vault-get influxdb_admin_user)";export INFLUX_PASSWORD="$(vault-get influxdb_admin_password)";
echo "export INFLUX_USERNAME=\"$INFLUX_USERNAME\"; export INFLUX_PASSWORD=\"$INFLUX_PASSWORD\";"
influx -ssl --unsafeSsl -username "$INFLUX_USERNAME" -password "$INFLUX_PASSWORD"
# Examples
show grants for "<example user>";
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

Note that the exported json files (with extension .dashboard) can not just be imported through the grafana UI, you need
to use the same grafana-backup-tool to do the restore, like so:

```bash
git clone https://github.com/ysde/grafana-backup-tool.git
export GRAFANA_URL="http://localhost:3001"; export GRAFANA_TOKEN="<token>";
python grafana-backup-tool/createDashboard.py dashboards/Overview.dashboard
```

# Miscellaneous notes

## Upgrading homeassistant

When upgrading homeassistant, you need to manually start it because on first run hass will install a bunch of additional packages.
Especially installing pyatv tends to take 10+ mins.

Try running
```bash
ps -ef | grep pip
```
# Virtualbox performance issues
I keep running into vagrant box lock ups. Some details of research I've done around this:

https://joeshaw.org/terrible-vagrant-virtualbox-performance-on-mac-os-x/

```
export CASA_VM=$(VBoxManage list vms | grep casa_home | cut -f1 -d" " | tr -d "\"")
VBoxManage storagectl $CASA_VM --name "IDE" --hostiocache on
```

TODO
```
NAT: Error(22) while setting RCV capacity to (65536)
```
## SCP

scp -P 2222 -i ~/repos/casa/.vagrant/machines/home/virtualbox/private_key ubuntu@127.0.0.1:/home/ubuntu/redis.conf .

## Hass APIs
```bash
export HASS_URL="http://0.0.0.0:8123"; export HASS_PASSWORD="$(awk '/api_password: /{print $2}'  /opt/homeassistant/configuration.yaml)"
# Getting  entity picture
curl -s -H "x-ha-access: $HASS_PASSWORD" -H "Content-Type: application/json" $HASS_URL/api/states/camera.hallway | jq -r ".attributes.entity_picture"
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

# Old stuff (keeping here for reference)
## Monit

Getting status from monit using API
```bash
# Status
curl -u "$CASA_MONIT_USERNAME:$CASA_MONIT_PASSWORD" http://localhost:2812/_status
curl -u "$CASA_MONIT_USERNAME:$CASA_MONIT_PASSWORD" http://localhost:2812/_status?format=xml
# Summary
curl -u "$CASA_MONIT_USERNAME:$CASA_MONIT_PASSWORD" http://localhost:2812/_summary
```

## Installing Raspbian

Use [etcher.io](https://etcher.io) to flash raspbian lite to SD card.
Then add an empty 'ssh' file to the SD card to enable SSH on boot on Raspbian.

