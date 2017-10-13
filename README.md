# casa

Home automation for the house :)

## Installing Raspbian

Use [etcher.io](https://etcher.io) to flash raspbian lite to SD card.
Then add an empty 'ssh' file to the SD card to enable SSH on boot on Raspbian.

## Running ansible

### Prerequisites

Install dependencies (best globally):
```bash
pip install -r requirements.txt
```

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

## Convenient commands

```bash
# Check logs
sudo journalctl -fu homeassistant@pi.service
# Restart server
sudo systemctl restart homeassistant@pi.service
# Get monit status
sudo monit status
sudo monit summary
```

Getting status from monit using API
```bash
# Status
curl -u "$CASA_MONIT_USERNAME:$CASA_MONIT_PASSWORD" http://localhost:2812/_status
curl -u "$CASA_MONIT_USERNAME:$CASA_MONIT_PASSWORD" http://localhost:2812/_status?format=xml
# Summary
curl -u "$CASA_MONIT_USERNAME:$CASA_MONIT_PASSWORD" http://localhost:2812/_summary
```

## Upgrading homeassistant

When upgrading homeassistant, you need to manually start it because on first run hass will install a bunch of additional packages.
Especially installing pyatv tends to take 10+ mins.

Try running 
```bash
ps -ef | grep pip
```

## Other convenient info

### Spotify/Sonos

Playing music on Sonos:
http://hasshostname:8123/dev-service
Domain: media_player
Service: select_source
Service Data: {"entity_id": "media_player.tv_room", "source": "'t Koffiehuis"}

Apparently, it's not that easy to play a playlist during a scene:
Some pointers on how to play spotify playlist here: https://community.home-assistant.io/t/sonos-automation-scenes-and-specific-playlists/3002/16

Also, sonos has a sonos_join service that should allow speakers to be paired up, need to look into that:
https://home-assistant.io/components/media_player.sonos/


## WIP
### AppleTV:
Some issues:
- https://community.home-assistant.io/t/apple-tv-apple-tv-failed-to-login/11694/53
- https://github.com/home-assistant/home-assistant/issues/6777


## TODO
- Groups: https://home-assistant.io/components/group/
- Spotify support:  https://home-assistant.io/components/media_player.spotify/
- Samsung smartTV support: https://home-assistant.io/components/media_player.samsungtv/
- Location tracking via OwnTracks
- https://home-assistant.io/components/media_player.cast/
- Let's encrypt support
- Calling "homeassistant/reload_core_config" one config reload instead of doing a HA restart

- HADashboard: Volume control

- Nest-cam: enable all cameras at once on leave or sleep