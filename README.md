# casa
Set of ansible playbooks that I use to maintain my [homeassistant](home-assistant.io)-based home automation stack.
This repository also contains playbooks for a bunch of auxillary systems that are part of my setup such as [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [ELK](https://www.elastic.co/elk-stack), [InfluxDB](https://docs.influxdata.com/influxdb), [AppDaemon](https://appdaemon.readthedocs.io/en/latest/) and some others.

**I maintain this purely for fun (often favoring speed and exploration over quality) and really only with my own use-cases
in mind, so use at your own risk! I don't expect the actual code to work for anyone but me, so please consider this as
more as a reference/demo rather than a plug-and-play solution.**

To get an idea of some of the automations I'm using, have a look at the [homeassistant](https://github.com/jorisroovers/casa/tree/master/roles/homeassistant/) directory.

*Screenshot of main dashboard running on wall-mounted iPads*
![HADashboard Home](docs/images/AppDaemon-Home.png)


# Table of Contents
- [General Notes](#General-Notes)
- [Screenshots](#Screenshots)
- [Setup Details](#Setup-Details)
  - [Hardware](#Hardware)
  - [Software](#Software)
- [Getting Started](#Getting-Started)

# General Notes

- You might see some references to ```casa-data```: this is a private repo I maintain that contains the actual
data relevant to my home (usernames, passwords, secrets, IP addresses, etc). The roles and playbooks in this repo all
use dummy defaults.
- Since my family's mother tongue is Dutch, you'll see some Dutch language used here and there
(mostly in the user-facing parts).
- I try to keep my setup completely disconnected from the Internet for security and privacy reasons. There are some exceptions (like some Nest devices I use), but those connect outward to the internet themselves - it's not possible to directly connect to any device from the Internet as everything runs in a private network.
- I'm constantly thinking of new things I can improve my setup and have a long list of TODO items I keep outside of this repository (this makes it easier to jot them down while not in front of a computer). Some bigger things that are a bit tricky (or expensive) but that I want to eventually get to are: automated sliding curtains, automated window opening, automated doorlocks.
- I have no idea how much time I've spend getting to this point, but I'm fairly certain it's a couple of hundreds of hours at least. Spread over about 2 years.
- I've never done a calculation of how much the current setup has cost me, but I'd roughly guess it's in the 2000-3000 EUR range. Note that it also highly depends on how you calculate things. Do you account for a (smart) TV? What about smart audio speakers? An old laptop that you had still lying around that you use as a server? Light bulbs you needed to buy anyways but you bought smartbulbs instead? etc.
- If you're new to home-automation and want to do something similar to this, I recommend getting a Raspberry Pi (get the latest model with the most compute power) and installing [HomeAssistant](https://www.home-assistant.io/) on it. Then get yourself a set of Philips Hue or Ikea Tradfri light bulbs and start playing!

# Screenshots

## Main Control interface
This interface is build in [appdaemon](https://appdaemon.readthedocs.io/en/latest/DASHBOARD_CREATION.html) (with some customizations) and displayed on 3 wall-mounted iPad minis around the house. We use as the primary way of interacting with the system. Under-the-hood this is just a webpage served from the main server and the iPads are just showing those as standalone webapps (=no browser chrome showing) with displays set to always-on.

### Home
![HADashboard Home](docs/images/AppDaemon-Home.png)

### Media
![HADashboard Media](docs/images/AppDaemon-Media.png)

### Security
![HADashboard Media](docs/images/AppDaemon-Security.png)

### Hallway
![HADashboard Media](docs/images/AppDaemon-Hallway.png)

### Upstairs
![HADashboard Media](docs/images/AppDaemon-Upstairs.png)

### Monitoring
![HADashboard Media](docs/images/AppDaemon-Monitoring.png)

## Homeassistant

In the background, [homeassistant](https://www.home-assistant.io/) is actually doing all the heavy lifting. While Homeassitant comes with its own UI, I only use it during development or troubleshooting. The main reason is that the interface is just not as user-friendly as the appdaemon dashboards for permanently wall-mounted tablets (in which big buttons are the way to go).
 With the introduction of [lovelace](https://www.home-assistant.io/lovelace/) more recently, the flexibilty to define your own UI has vastly improved, but from what I've seen and read I still find my existing appdaemon dashboard more appealing. In addition, it would be a considerable amount of effort for me to port all my customizations over to lovelace. One day maybe?

### Homeassistant Default interface
![Homeasisstant Home](docs/images/Homeassistant-Home.png)


## Grafana
I use [Grafana](https://grafana.com/) to display metrics from Homeassistant, InfluxDB and Prometheus.

### Server health
![Grafana Server Health](docs/images/Grafana-Overview.png)

### House Statistics
![Grafana Stats](docs/images/Grafana-Stats.png)

## Prometheus

I use [Prometheus](https://prometheus.io/) with [Node Exporter](https://github.com/prometheus/node_exporter), [Process Exporter](https://github.com/ncabatoff/process-exporter), [Blackbox exporter](https://github.com/prometheus/blackbox_exporter) and [Alert Manager](https://prometheus.io/docs/alerting/alertmanager/) to do monitor and alerting of my whole setup.

### Prometheus Alerts 
![Prometheus Alerts](docs/images/Prometheus-Alerts.png)

# Setup Details
## Hardware

I host the whole stack on a [2011 Macbook Pro](https://support.apple.com/kb/SP619?locale=en_US) with a 2.7GHz dual-core i7 and 8GB of memory running Ubuntu 17.10. While the machine can easily handle the load, I expect that at some point I'll replace it with something that is more suited for running 24x7 - I have some concerns about fire safety with the Macbook's built-in battery.

Here's a list of home-automation gear I currently have around my house:

| Hardware                                                                        | Notes                                   |
| ------------------------------------------------------------------------------- | ------------------- |
| [Sonos play 5, play 1, play base](https://www.sonos.com/en/shop/)               | Internet controllable quality speakers  |
| [Philips Hue](https://www2.meethue.com/en-us)                                   | Light bulbs, switches            |
| [Ikea Tradfri](https://www.ikea.com/us/en/catalog/products/20411562/)                                                                    | Light bulbs, switches, movement sensors |
| [Nest Cam](https://nest.com/cameras/)                                           | Security monitoring (also remotely). Own various models. |
| [Nest Thermostat](https://nest.com/thermostats/)                                | Climate control                         |
| [HomeMatic HmIP-CCU3](https://www.eq-3.com/products/homematic/control-units-and-gateways/-473.html) |  HomeMatic control unit  |
| [HomeMatic HM-CC-RT-DN](https://www.eq-3.com/products/homematic/heating-and-climate-control/homematic-wireless-radiator-thermostat.html#bestell_info)                         | Smart Radiator valves. Allows me to control temperature for radiators upstairs where I have no separate thermostat and heating circuit. |
| [Nest Protect smoke detectors](https://nest.com/smoke-co-alarm/overview/)      | Smart Smoke detectors  |
| [TP link HS100 and HS110 Power Switches](https://www.kasasmart.com/us/products/smart-plugs/kasa-smart-plug-energy-monitoring-hs110)                                          | Washing Machine and Dryer power monitoring (to detect whether they're running or not) |
| Samsung SmartTV UE48H6200AW                                                     | Our main TV - couple years old but has some basic smartTV features.  |
| [Wemos D1](https://wiki.wemos.cc/products:d1:d1)                                | A simple custom-build sensor using a cheap Arduino compatible board and an ultrasonic sensor to measure the current height of my standing desk. This allows me to track how much time I've been standing during the day. |
| [Aeotec Zwave Stick Gen5](https://aeotec.com/z-wave-usb-stick)                   | Simple [Z-wave](https://www.z-wave.com/) controller in USB-stick form factor |
| [Aeotec ZW100 MultiSensor](https://aeotec.com/z-wave-sensor)                     | Multi-sensor. Used to detect movement, temperature and humidity in bathroom |
| [iPad mini (Gen 2, Gen 4)](https://www.apple.com/lae/ipad-mini/)                                                        | Wall Mounted control panels             |
| [Raspberry Pi](https://www.raspberrypi.org/) + [DSMR](https://www.home-assistant.io/components/dsmr/)           | Raspberry Pi connected to smart energy meter for energy monitoring.  |


Other gear I have that is currently not (yet) integrated in the setup:
| Hardware                                                                        | Notes         |
| ------------------------------------------------------------------------------- | ------------------- |
| [AppleTV](https://www.apple.com/lae/tv/)                                        | There are some issues with [pyatv](https://github.com/postlund/pyatv) turning on the TV randomly that prevent me from properly integrating this |
| [Elgato Eve Window sensor](https://www.evehome.com/en/eve-door-window)          | HomeKit only. Not currently using. |
| [Elgato Eve Power plug](https://www.evehome.com/en/eve-energy)                  | Homekit only. Reset wifi every night at 4AM. Blue-tooth based. Ability to reset network even when whole network is down |
| [Amazon Echo dot](https://www.amazon.com/All-new-Echo-Dot-3rd-Gen/dp/B0792KTHKJ)              | Integration not possible without exposing homeasisstant to the internet. Still brainstorming on workarounds |
| [Chromecast](https://store.google.com/product/chromecast)                       | We usually use our AppleTV(s) instead |

## Software Stack

The best way to get a quick overview of the software stack is to look at roles directory


| Software                                                                        | Description         |
| ------------------------------------------------------------------------------- | ------------------- |
| Ubuntu 17.10                                                                    | Operating System   |
| [Homeassistant](https://home-assistant.io/)                                     | Main platform that integrates everything together                    |
| [HADashboard](http://appdaemon.readthedocs.io/en/stable/DASHBOARD_INSTALL.html) |                     |
| [node-sonos-http-api](https://github.com/jishi/node-sonos-http-api)             |                     |
| InfluxDB                                                                        |                     |
| Grafana                                                                         |                     |
| Logstash                                                                        |                     |
| [Slack](https://slack.com/)               |                     |
| Docker                                                                          |                     |
| roofcam                                                                         |                     |
| ELK                                                                             |                     |
| [Prometheus](https://prometheus.io/)                                            |   |
[Node Exporter](https://github.com/prometheus/node_exporter)
[Process Exporter](https://github.com/ncabatoff/process-exporter)
[Blackbox Exporter](https://github.com/prometheus/blackbox_exporter)
[Alert Manager](https://prometheus.io/docs/alerting/alertmanager/)

Selenium
Sanity tests
Trash detection
https://github.com/McKael/samtv
Backups
prom2hass
Seshat
Ser2net
Password combo
Slack


| [Sensu](https://sensu.io/) | I migrated from Monit to Sensu for monitoring but over time that ended up consuming way too much CPU and memory which tended to slow my whole stack down. Currently on Prometheus. |
| [Monit](https://mmonit.com/monit/) | When I started out, I used Monit for simple monitoring but I quickly required more elaborate monitoring capabilities |

# Getting Started
**Ok, the title of this section is a bit of a lie. Like I've mentioned at the start of this README, I don't really expect this playbook to work for anyone but me. But if you ARE me, here's how you actually run this against your target hosts.**

Note: I'm currently using Ansible 2.4.2 and am using some Ansible 2.4 specific features in the playbooks, so that's the version of Ansible you'll need :)

## PROD

```bash
ansible-playbook -i ~/repos/casa-data/inventory/prod --tags node_exporter --limit controller home.yml

# Only run 'node_exporter' tag against target energy_tracker host
ansible-playbook -i ~/repos/casa-data/inventory/prod --tags node_exporter --limit energy* home.yml
```

## DEV
In the past I did development locally on a VM using Vagrant, but with the amount of sensors and containers involved, that no longer works well. For reference though:
```bash
vagrant up
ansible-playbook home.yml -i inventory/vagrant
# roofcam only
ansible-playbook home.yml -i inventory/vagrant --tags roofcam
# using production data
ansible-playbook home.yml -i  ~/repos/casa-data/inventory/vagrant
```