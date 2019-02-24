import datetime
import requests

################################################################################
# Config
HASS_API_PASSWORD = "{{homeassistant_http.api_password}}"
HASS_HOST = "http://0.0.0.0:{{homeassistant_port}}"
PROMETHEUS_HOST = "http://0.0.0.0:{{prometheus_port}}"
DEBUG = True

################################################################################
# Utility Functions


def debug(msg):
    if DEBUG:
        print(msg)


def create_sensor(sensor_type, sensor_name, payload):
    debug("Making API call to Homeassistant to install sensor {0}.{1}".format(sensor_type, sensor_name))
    headers = {"x-ha-access": HASS_API_PASSWORD, "Content-Type": "application/json"}
    url = "{0}/api/states/{1}.{2}".format(HASS_HOST, sensor_type, sensor_name)
    resp = requests.post(url, json=payload, headers=headers, timeout=2)
    debug("DONE ({0})".format(resp))


################################################################################
# SENSORS
debug("Fetching sensors from prometheus...")
resp = requests.get(PROMETHEUS_HOST + "/api/v1/query?query={homeassistant='yes'}", timeout=2)

debug("Adding sensors from homeassistant...")
data = resp.json()['data']['result']
for item in data:
    sensor_type = item['metric'].get("homeassistant_sensor_type", "sensor")
    sensor_state = item['value'][1]
    payload = {
        "state": "{}".format(sensor_state),
        "attributes": {
            "friendly_name": item['metric']['__name__'],
            "source": "prometheus",
            "type": "prometheus-sensor",
            "timestamp": item['value'][0]
        }
    }
    create_sensor(sensor_type, item['metric']['__name__'], payload)


################################################################################
# ALERTS
debug("Fetching alerts from prometheus...")
resp = requests.get(PROMETHEUS_HOST + "/api/v1/rules", timeout=2)
data = resp.json()['data']

debug("Adding alerts as sensors from homeassistant...")
aggregate_state = "on"
timestamp = datetime.datetime.now().timestamp()
for group in data['groups']:
    for rule in group['rules']:
        if len(rule['alerts']) > 0:
            rule_alerts = rule['alerts'][0]['state']
        else:
            rule_alerts = None

        if rule_alerts:
            sensor_state = "off"
            aggregate_state = "off"
        else:
            sensor_state = "on"

        sensor_name = rule['name'].replace(".", "_").replace("-", "_")
        payload = {
            "state": "{}".format(sensor_state),
            "attributes": {
                "friendly_name": sensor_name,
                "source": "prometheus",
                "type": "prometheus-alert",
                "timestamp": timestamp
            }
        }
        create_sensor("binary_sensor", sensor_name, payload)

debug("Adding aggregate alert sensor to homeassistant...")
payload['state'] = aggregate_state
payload['attributes']['friendly_name'] = "prometheus_aggregate"
create_sensor("binary_sensor", "prometheus_aggregate", payload)
