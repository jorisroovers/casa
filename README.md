# casa

Home automation for the house :)

## Installing Raspbian

Use etcher.io to flash raspbian lite to SD card.
Then add an empty 'ssh' file to the SD card to enable SSH on boot on Raspbian.

## Running ansible

```bash
ansible-playbook --ask-pass home.yml -i inventory/hosts
# roofcam only
ansible-playbook --ask-pass home.yml -i inventory/hosts --tags roofcam
```


Checking logs

```
sudo journalctl -ru homeassistant@pi.service
```

## Upgrading homeassistant

When upgrading homeassistant, you need to manually start it because on first run hass will install a bunch of additional packages.

## TODO

- Spotify support:  https://home-assistant.io/components/media_player.spotify/
- Samsung smartTV support: https://home-assistant.io/components/media_player.samsungtv/
- AppleTV: https://home-assistant.io/components/media_player.apple_tv/ -> homesharing must be enabled
- Nest
- Location tracking via iOS app
- 