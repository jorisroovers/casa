# casa

Home automation for the house :)


```bash
ansible-playbook --ask-pass home.yml -i inventory/hosts
# roofcam only
ansible-playbook --ask-pass home.yml -i inventory/hosts --tags roofcam
```

CHecking logs

```
sudo journalctl -ru homeassistant@pi.service
```

## Upgrading homeassistant

When upgrading homeassistant, you need to manually start it because on first run hass will install a bunch of additional packages.