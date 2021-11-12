#!/usr/bin/env python3
from bs4 import BeautifulSoup
import datetime
import logging
import os
import requests


########################################################################################################################
# Setup Logging


def setup_logging():
    """ Setup logging """
    root_log = logging.getLogger("afvalwijzer")
    root_log.propagate = False  # Don't propagate to child loggers
    handler = logging.StreamHandler()
    formatter = logging.Formatter("%(asctime)s %(levelname)s: %(name)s %(message)s", "%Y-%m-%d %H:%M:%S")
    handler.setFormatter(formatter)
    root_log.addHandler(handler)
    root_log.setLevel(logging.INFO)

setup_logging()
LOG = logging.getLogger("afvalwijzer")

########################################################################################################################
# Check the correct env vars are set

for env_var in ['AFVALWIJZER_ZIPCODE', 'AFVALWIJZER_HOUSENUMBER', 'HASS_API_TOKEN', 'HASS_HOST']:
    if not env_var in os.environ:
        LOG.fatal("Environment variable {0} required".format(env_var))
        exit(1)

########################################################################################################################
# Utility functions


def create_sensor(sensor_type, sensor_name, payload):
    LOG.info("Making API call to Homeassistant to install sensor {0}.{1}".format(sensor_type, sensor_name))
    headers = {"Authorization": "Bearer {0}".format(os.environ['HASS_API_TOKEN']), "Content-Type": "application/json"}
    url = "{0}/api/states/{1}.{2}".format(os.environ['HASS_HOST'], sensor_type, sensor_name)
    resp = requests.post(url, json=payload, headers=headers, timeout=2)
    LOG.info("DONE ({0})".format(resp))

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
    LOG.info("Found cached file %s", CACHE_FILE)
    st = os.stat(CACHE_FILE)
    time_delta = int(now.timestamp() - st.st_mtime)
    LOG.info("Cache age is {0} secs (max age = {1})".format(time_delta, CACHE_MAX_AGE_SEC))
    if time_delta > CACHE_MAX_AGE_SEC:
        LOG.info("Cache age > {1} secs, refreshing the cache...".format(time_delta, CACHE_MAX_AGE_SEC))
        use_cache = False

if use_cache:
    LOG.info("Reading content from cache ({0})".format(CACHE_FILE))
    content = open(CACHE_FILE, "r").read()
else:
    url = "https://www.mijnafvalwijzer.nl/nl/{0}/{1}/".format(os.environ['AFVALWIJZER_ZIPCODE'],
                                                              os.environ['AFVALWIJZER_HOUSENUMBER'])
    LOG.info("Getting afvalwijzer details from {0}".format(url))
    resp = requests.get(url)
    content = resp.content

    LOG.info("Saving content to cache ({0})".format(CACHE_FILE))

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
        LOG.debug("Trash Type %s", trash_type)
        date_nl_span = p_items[0].find("span", recursive=False)
        date_nl = date_nl_span.find(text=True, recursive=False).strip()
        LOG.debug("Date NL %s", date_nl)
        date_nl_parts = date_nl.split(" ")
        # Set pick-up time at 11AM in the morning
        parsed_date = datetime.datetime(now.year, MONTHS[date_nl_parts[2]], int(date_nl_parts[1]), 11, 00)
        trash_pickups.append((parsed_date, trash_type))


trash_pickups = sorted(trash_pickups, key=lambda i: i[0])
next_pickup = next((i for i in trash_pickups if i[0] >= now), None)
next_pickup_plastic = next((i for i in trash_pickups if (i[0] >= now and i[1] == "plastic")), None)
next_pickup_gft = next((i for i in trash_pickups if (i[0] >= now and i[1] == "gft")), None)
next_pickup_paper = next((i for i in trash_pickups if (i[0] >= now and i[1] == "papier")), None)


#######################################################################################################################
# Create homeassistant sensors

# Next pickup
payload = {
    "state": next_pickup[1],
    "attributes": {
        "friendly_name": "afvalwijzer_next_pickup_" + next_pickup[1],
        "pickup_time": next_pickup[0].timestamp(),
        "pickup_date": next_pickup[0].strftime("%Y-%m-%d"),
        "pickup_type": next_pickup[1],
        "updated": now.timestamp()
    }
}
create_sensor("sensor", "afvalwijzer_next_pickup", payload)

# Next pickups for specific trash types
next_trash_pickups = [next_pickup_plastic, next_pickup_gft, next_pickup_paper]

for pickup in next_trash_pickups:

    payload = {
        "state": pickup[1],
        "attributes": {
            "friendly_name": "afvalwijzer_next_pickup_" + pickup[1],
            "pickup_time": pickup[0].timestamp(),
            "pickup_date": pickup[0].strftime("%Y-%m-%d"),
            "pickup_type": pickup[1],
            "updated": now.timestamp()
        }
    }
    create_sensor("sensor", "afvalwijzer_next_pickup_" + pickup[1], payload)
