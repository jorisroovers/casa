# casa

Home automation for the house :)

## Installing Raspbian

Use [etcher.io](https://etcher.io) to flash raspbian lite to SD card.
Then add an empty 'ssh' file to the SD card to enable SSH on boot on Raspbian.

## Running ansible
**Ansible version >= 2.3 required because of use of [ansible-vault single encrypted variables](http://docs.ansible.com/ansible/latest/playbooks_vault.html#single-encrypted-variable)**

Development should be done locally in Vagrant.
### DEV
```bash
vagrant up
ansible-playbook --ask-vault-pass home.yml -i inventory/vagrant 
# roofcam only
ansible-playbook --ask-vault-pass home.yml -i inventory/vagrant --tags roofcam
```
### PROD

```bash
ansible-playbook --ask-pass --ask-sudo-pass --ask-vault-pass home.yml -i inventory/mbp-server
# roofcam only
ansible-playbook --ask-pass --ask-sudo-pass --ask-vault-pass home.yml -i inventory/mbp-server --tags roofcam
```

## Convenient commands

```bash
# Check logs
sudo journalctl -fu homeassistant@pi.service
# Restart server
sudo systemctl restart homeassistant@pi.service
```

Encrypting values using vault:

```bash
ansible-vault encrypt_string "mySecretValue"
```

## Upgrading homeassistant

When upgrading homeassistant, you need to manually start it because on first run hass will install a bunch of additional packages.
Especially installing pyatv tends to take 10+ mins.

Try running 
```bash
ps -ef | grep pip
```

## WIP
### AppleTV:
Some issues:
- https://community.home-assistant.io/t/apple-tv-apple-tv-failed-to-login/11694/53
- https://github.com/home-assistant/home-assistant/issues/6777


## TODO
- Groups: https://home-assistant.io/components/group/
- Spotify support:  https://home-assistant.io/components/media_player.spotify/
- Samsung smartTV support: https://home-assistant.io/components/media_player.samsungtv/
- Location tracking via iOS app
- https://home-assistant.io/components/media_player.cast/
- Google Travel time: https://home-assistant.io/components/sensor.google_travel_time/