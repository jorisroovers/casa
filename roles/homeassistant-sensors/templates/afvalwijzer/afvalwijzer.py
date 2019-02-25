#!/usr/bin/env python3
from bs4 import BeautifulSoup
import datetime
import os
import requests

for env_var in ['AFVALWIJZER_ZIPCODE', 'AFVALWIJZER_HOUSENUMBER', 'HASS_API_PASSWORD', 'HASS_HOST']:
    if not env_var in os.environ:
        print("Environment variable {0} required".format(env_var))
        exit(1)

########################################################################################################################
# Utility functions


def create_sensor(sensor_type, sensor_name, payload):
    print("Making API call to Homeassistant to install sensor {0}.{1}".format(sensor_type, sensor_name))
    headers = {"x-ha-access": os.environ['HASS_API_PASSWORD'], "Content-Type": "application/json"}
    url = "{0}/api/states/{1}.{2}".format(os.environ['HASS_HOST'], sensor_type, sensor_name)
    resp = requests.post(url, json=payload, headers=headers, timeout=2)
    print("DONE ({0})".format(resp))

########################################################################################################################
# Fetch html page from afvalwijzer.nl
# Cache the page so we don't have to fetch it all the time (since it rarely changes)


CACHE_FILE = "/tmp/afvalwijzer-{0}-{1}.cache.html".format(os.environ['AFVALWIJZER_ZIPCODE'],
                                                          os.environ['AFVALWIJZER_HOUSENUMBER'])

CACHE_MAX_AGE_SEC = 60 * 60 * 24  # 24 hrs in sec = 60 sec * 60 min * 24 hrs
use_cache = False

now = datetime.datetime.now()

if os.path.isfile(CACHE_FILE):
    use_cache = True
    print("Found cached file", CACHE_FILE)
    st = os.stat(CACHE_FILE)
    time_delta = int(now.timestamp() - st.st_mtime)
    print("Cache age is {0} secs (max age = {1})".format(time_delta, CACHE_MAX_AGE_SEC))
    if time_delta > CACHE_MAX_AGE_SEC:
        print("Cache age > {1} secs, refreshing the cache...".format(time_delta, CACHE_MAX_AGE_SEC))
        use_cache = False

if use_cache:
    print("Reading content from cache ({0})".format(CACHE_FILE))
    content = open(CACHE_FILE, "r").read()
else:
    url = "https://www.mijnafvalwijzer.nl/nl/{0}/{1}/".format(os.environ['AFVALWIJZER_ZIPCODE'],
                                                              os.environ['AFVALWIJZER_HOUSENUMBER'])
    print("Getting afvalwijzer details from {0}".format(url))
    resp = requests.get(url)
    content = resp.content

    print("Saving content to cache ({0})".format(CACHE_FILE))

    # write fetched content to cache
    with open(CACHE_FILE, "w") as f:
        f.write(str(content))


#######################################################################################################################
# Parse HTML page fetched from afvalwijzer.nl

MONTHS = {"januari": 1, "februari": 2, "maart": 3, "april": 4, "mei": 5,
          "juni": 6, "juli": 7, "augustus": 8, "september": 9, "oktober": 10,
          "november": 11, "december": 12}


trash_pickups = []

soup = BeautifulSoup(content, 'html.parser')
for item in soup.find_all("a", class_="wasteInfoIcon"):
    p_items = item.find_all("p")
    if len(p_items) > 0:
        trash_type = p_items[0]['class'][0]
        date_nl = p_items[0].find(text=True, recursive=False).strip()
        date_nl_parts = date_nl.split(" ")
        # Set pick-up time at 8AM in the morning
        parsed_date = datetime.datetime(now.year, MONTHS[date_nl_parts[2]], int(date_nl_parts[1]), 8, 00)
        trash_pickups.append((parsed_date, trash_type))


trash_pickups = sorted(trash_pickups, key=lambda i: i[0])
next_pickup = next((i for i in trash_pickups if i[0] >= now), None)
next_pickup_plastic = next((i for i in trash_pickups if (i[0] >= now and i[1] == "plastic")), None)
next_pickup_gft = next((i for i in trash_pickups if (i[0] >= now and i[1] == "gft")), None)
next_pickup_paper = next((i for i in trash_pickups if (i[0] >= now and i[1] == "papier")), None)

next_pickup_sensor = {}

payload = {
    "state": next_pickup[1],
    "attributes": {
        "friendly_name": "afvalwijzer_next_pickup",
        "pickup_time": next_pickup[0].timestamp(),
        "pickup_date": next_pickup[0].strftime("%Y-%m-%d"),
        "pickup_type": next_pickup[1],
        "updated": now.timestamp()
    }
}

create_sensor("sensor", "afvalwijzer_next_pickup", payload)

print("NEXT", next_pickup)
print("next plastic", next_pickup_plastic)
print("next gft", next_pickup_gft)
print("next paper", next_pickup_paper)
