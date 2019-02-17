
# Running selenium
Easiest way is to just run a local docker with selenium-chrome in it
```sh
# On Mac:
docker run -d -p 4444:4444 --name selenium selenium/standalone-chrome:3.141.59

# On Linux:
docker run -d -p 4444:4444 -v /dev/shm:/dev/shm --name selenium selenium/standalone-chrome:3.141.59
```

# Running tests

## Development

```sh
pytest -rw -s --hadashboard-url http://$HASS_IP:5050 --homeassistant-url http://$HASS_IP:8123 --homeassistant-password "$(vault-get ' api_password')" test_homeassistant.py::test_group_entities


# Run tests marked as 'sanity'
pytest -rw -s -m sanity --hadashboard-url http://$HASS_IP:5050 --homeassistant-url http://$HASS_IP:8123 --homeassistant-password "$(vault-get ' api_password')"
```

## Production (docker)

```sh
# Build the test container
# From the tests/ directory:
docker build -t casa-tests .

# Against
docker run casa-tests pytest -rw -s --hadashboard-url http://$HASS_IP:5050 --homeassistant-url http://$HASS_IP:8123 --homeassistant-password "$(vault-get ' api_password')" --remote-driver-url http://127.0.0.1:4444/wd/hub test_homeassistant.py::test_group_entities


```