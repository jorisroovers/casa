# casa
Home-automation stack based on [homeassistant](home-assistant.io), orchestrated through [Ansible](https://www.ansible.com/).
This repository also contains ansible playbooks for a bunch of auxillary systems that are part of my setup such as [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [ELK](https://www.elastic.co/elk-stack), [AppDaemon](https://appdaemon.readthedocs.io/en/latest/) and some others (see  below).

To get an idea of some of the automations I'm using, I recommend reading my blogpost: [My Favorite Home Automations](https://jorisroovers.com/posts/my-favorite-home-automations)

**I maintain this purely for fun (favoring speed and exploration over quality and documentation) and really only with my own use-cases
in mind, so use at your own risk! I don't expect the actual code to work for anyone but me, so please consider this as
more as a reference/demo rather than a plug-and-play solution.**

**Currently doing some maintenance on this README**

*Screenshot of main dashboard running on wall-mounted iPads*
![HADashboard Home](docs/images/AppDaemon-Home.png)

# Menu
- [casa](#casa)
- [Menu](#menu)
- [Interface Screenshots](#interface-screenshots)
    - [Home](#home)
- [Details](#details)
  - [Hubs](#hubs)
  - [Climate](#climate)
  - [Windows/Curtains](#windowscurtains)
  - [Lights](#lights)
  - [Switches](#switches)
  - [Voice Control](#voice-control)
  - [Security](#security)
  - [Sensors](#sensors)
  - [Media](#media)
  - [Other Hardware](#other-hardware)
  - [Software](#software)
  - [Supporting Software](#supporting-software)
- [Retired](#retired)
  - [Retired Hardware](#retired-hardware)
  - [Retired Software](#retired-software)
- [Customized](#customized)
  - [Home-assistant details](#home-assistant-details)
- [Future Work](#future-work)
- [General Notes](#general-notes)
- [Getting Started](#getting-started)
  - [PROD](#prod)
  - [DEV](#dev)

# Interface Screenshots

The main interface is build in [appdaemon](https://appdaemon.readthedocs.io/en/latest/DASHBOARD_CREATION.html) (with some customizations) and displayed on wall-mounted iPad minis around the house. This is our primary way of interacting with the system. Under-the-hood this is just a webpage served from the main server and the iPads are just showing those as standalone webapps (=no browser chrome showing) with displays set to always-on. The first iPad I mounted has been continuously running for over 3 years without issues.

In the background, [homeassistant](https://www.home-assistant.io/) is doing all the heavy lifting. While Homeassistant comes with its own UI, I only use it during development or troubleshooting. With the introduction of [lovelace](https://www.home-assistant.io/lovelace/) more recently, the flexibility to define your own UI has vastly improved though, and I'm evaluating whether to replace the appdaemon interface with lovelace.

### Home
<table>
  <tr>
    <td>
      <img alt="HADashboard Home" src="docs/images/AppDaemon-Home.png"><br>
      Homescreen
    </td>
    <td height="130">
      <img alt="HADashboard Media" src="docs/images/AppDaemon-Media.png"><br>
      Media Controls
    </td>
    <td>
      <img alt="HADashboard Security" src="docs/images/AppDaemon-Security.png"><br>
      Security
    </td>
  </tr>
  <tr>
    <td>
      <img alt="HADashboard Hallway" src="docs/images/AppDaemon-Hallway.png"><br>
      Hallway
    </td>
    <td height="130">
      <img alt="HADashboard Upstairs" src="docs/images/AppDaemon-Upstairs.png"><br>
      Upstairs
    </td>
    <td>
      <img alt="HADashboard Monitoring" src="docs/images/AppDaemon-Monitoring.png"><br>
      Monitoring
    </td>
  </tr>
  <tr>
    <td>
      <img alt="HADashboard Phone" src="docs/images/AppDaemon-Phone.png"><br>
      Smartphone interface
    </td>
    <td >
      <img alt="Homeassistant default" src="docs/images/HomeAssistant-Home.png"><br>
      Home-assistant default interface
    </td>
    <td>
        <img alt="Grafana server health" src="docs/images/Grafana-Overview.png"><br>
        Grafana Server Health stats
    </td>
  </tr>
   <tr>
    <td>
        <img alt="Grafana House Stats" src="docs/images/Grafana-Stats.png"><br>
        Grafana House Stats
    </td>
    <td height="130">
        <img alt="Homeassistant default" src="docs/images/Prometheus-Alerts.png"><br>
        Prometheus Alerts
    </td>
    <td>
     <img alt="Homeassistant default" src="docs/images/Prometheus-Alerts.png"><br>
        Test
    </td>
  </tr>
</table>

# Details
## Hubs

| Device                      | Homeassistant                                       | Notes 
| ----------------------------|---------------------------------------------------- | ------------------- |                                  
| [Philips Hue Hub v2](https://www2.meethue.com/en-us) |  [Philips Hue](https://www.home-assistant.io/components/hue/) | Used to control all Philips Hue Light bulbs, switches            |
| [Ikea Trådfri](https://www.ikea.com/us/en/catalog/products/20411562/)        | [Ikea Tradfri](https://www.home-assistant.io/integrations/tradfri/) | Use the control all IKEA Trådfri light bulbs, switches, movement sensors |
| [HomeMatic HmIP-CCU3](https://www.eq-3.com/products/homematic/control-units-and-gateways/-473.html) | [HomeMatic](https://www.home-assistant.io/integrations/homematic)  | HomeMatic control unit, used for smart radiator valves  |
| [Aeotec Zwave Stick Gen5](https://aeotec.com/z-wave-usb-stick)       |    [Zwave](https://www.home-assistant.io/integrations/zwave/)         | Simple [Z-wave](https://www.z-wave.com/) controller in USB-stick form factor |
## Climate

| Device                      | Homeassistant                                       | Notes   
| ----------------------------|---------------------------------------------------- | ------------------- | 
| [Nest Thermostat](https://nest.com/thermostats/)      | [Nest](https://www.home-assistant.io/components/nest/)                           | Smart climate control                         |
| [HomeMatic HM-CC-RT-DN](https://www.eq-3.com/products/homematic/heating-and-climate-control/homematic-wireless-radiator-thermostat.html#bestell_info)  | [HomeMatic](https://www.home-assistant.io/integrations/homematic)   | Smart Radiator valves. Allows me to control temperature for radiators upstairs where I have no separate thermostat and heating circuit. |  


## Windows/Curtains

| Device                      | Homeassistant                                       | Notes   
| ----------------------------|---------------------------------------------------- | ------------------- | 
| [Custom Window Opener](https://github.com/jorisroovers/window-opener)   | [ESPHome](https://www.home-assistant.io/integrations/esphome/)           | A custom-build motorized widget to open our bedroom window. I wrote a [lengthy blog-post](https://jorisroovers.com/posts/window-opener) about how I build it. |
| [Dooya Smart Curtain](http://www.dooya.com/solve_en.php?id=37&nid=48)   | [ESPHome](https://www.home-assistant.io/integrations/esphome/)| Custom solution for smart curtains. [Detailed Write-up](projects/curtain-opener/README.md)  |

## Lights

| Device                      | Homeassistant                                       | Notes   
| ----------------------------|---------------------------------------------------- | ------------------- |
| Hue color bulb       | [Philips Hue](https://www.home-assistant.io/components/hue/)                             | Color light bulbs            |
| Hue ambience bulb       | [Philips Hue](https://www.home-assistant.io/components/hue/)                             | Ambience bulbs (=white spectrum only)            |
| Hue ambience spot       | [Philips Hue](https://www.home-assistant.io/components/hue/)                             | Spot ambience lights, GU10 sockets used in Kitchen            |
| Hue dimmer switch       | [Philips Hue](https://www.home-assistant.io/components/hue/)                             | Dimmer switch for nightstand lamps         |
| Trådfri ambience bulb |  [Ikea Trådfri](https://www.home-assistant.io/integrations/tradfri/)                        | Movement sensors |
| Trådfri ambience spot |  [Ikea Trådfri](https://www.home-assistant.io/integrations/tradfri/)                        | 
| Trådfri LED panel |  [Ikea Trådfri](https://www.home-assistant.io/integrations/tradfri/)                        | Smart LED panel |
| Trådfri motion sensor |  [Ikea Tradfri](https://www.home-assistant.io/integrations/tradfri/)                        | Motion sensors, used to automatically control lights in hallway, pantry, toilet |
| Trådfri remote control |  [Ikea Tradfri](https://www.home-assistant.io/integrations/tradfri/)                        | Remote control, used to manually control lights |

## Switches
| Device                      | Homeassistant                                       | Notes   
| ----------------------------|---------------------------------------------------- | ------------------- |    
| [TPLink HS100)](https://www.kasasmart.com/us/products/smart-plugs/kasa-smart-wifi-plug-hs100)    | [TP-Link](https://www.home-assistant.io/integrations/tplink/)                                      | Automatic power switching of some devices: office standing lamp, bathroom mirror, christmas tree, etc. [I do NOT recommend using TPLink smartplugs](https://alerts.home-assistant.io/#tplink.markdown) |
| [TPLink HS110)](https://www.kasasmart.com/us/products/smart-plugs/kasa-smart-plug-energy-monitoring-hs110)    | [TP-Link](https://www.home-assistant.io/integrations/tplink/)                                      | Washing Machine and Dryer power monitoring (to detect whether they're running or not). [I do NOT recommend using TPLink smartplugs](https://alerts.home-assistant.io/#tplink.markdown) |
## Voice Control
| Device                      | Homeassistant                                       | Notes   
| ----------------------------|---------------------------------------------------- | ------------------- |    
| [Amazon Echo dot (v2, v3)](https://www.amazon.com/All-new-Echo-Dot-3rd-Gen/dp/B0792KTHKJ)              | [Emulated Hue](https://www.home-assistant.io/components/emulated_hue/) | Allows for alexa integration without exposing the stack to the internet. |
| None | [Amazon Polly](https://www.home-assistant.io/components/amazon_polly/) | AWS Text-to-Speech engine. Allows the house to talk back (e.g. "Good Night!"). Cool? Yes. Nerdy? For sure. |

## Security
| Device                      | Homeassistant                                       | Notes   
| ----------------------------|---------------------------------------------------- | ------------------- |   
| [Nest Cam](https://nest.com/cameras/)                                           | [Nest](https://www.home-assistant.io/components/nest/) | Security monitoring (also remotely). Own various models. | 
| [Nest Protect smoke detectors](https://nest.com/smoke-co-alarm/overview/) | [Nest](https://www.home-assistant.io/components/nest/)     | Smart Smoke detectors  |

## Sensors
| Device                      | Homeassistant                                       | Notes   
| ----------------------------|---------------------------------------------------- | ------------------- |    
| [Aeotec ZW100 MultiSensor](https://aeotec.com/z-wave-sensor)  | [Zwave](https://www.home-assistant.io/integrations/zwave/)                   | Multi-sensor. Used to detect movement, temperature and humidity in bathroom |
| Raspberry Pi + [Serial-to-USB cable](https://www.sossolutions.nl/slimme-meter-kabel) | [Sensor - DSMR](https://www.home-assistant.io/components/dsmr/) | Energy monitoring using the Dutch DSMR energy monitoring protocol |
| [Desk-height](https://github.com/jorisroovers/casa/tree/master/projects/deskheight/main) | NA | Simple Arduino-based sensor to determine the current height of my standing desk using an ultrasonic sensor mounted underneath it. This info is then send over to my home server which does some simple processing in logstash and home-assistant to determine whether the desk is up or down. This is then used to calculate and show standing time statistics in grafana. |


## Media

| Device                      | Homeassistant                                       | Notes   
| ----------------------------|---------------------------------------------------- | ------------------- |   
| [Samsung SmartTV QE55Q70R](https://www.samsung.com/nl/tvs/qled-4k-q70r/QE55Q70RALXXN)  | [SamsungTV](https://www.home-assistant.io/integrations/samsungtv)                                                    | Our main TV  |
| [Sonos play 5, play 1, play base, move](https://www.sonos.com/en/shop/)   | [Sonos](https://www.home-assistant.io/integrations/sonos)            | Internet controllable quality speakers  |
| [AppleTV 4K](https://www.apple.com/lae/tv/)                                        | [AppleTV](https://www.home-assistant.io/integrations/apple_tv) |  There are some issues with the Home-assistant AppleTV integration ([pyatv](https://github.com/postlund/pyatv) in particular) thta will cause connected TVs to turn on semi-randomly that prevent me from properly integrating this. |
| [AppleTV](https://www.apple.com/lae/tv/)      | [AppleTV](https://www.home-assistant.io/integrations/apple_tv)                                    | Attached to non-4K TV |
## Other Hardware

| Device                                                                        | Notes                                   |
| ------------------------------------------------------------------------------- | ------------------- |
[2011 Macbook Pro](https://support.apple.com/kb/SP619?locale=en_US) | Old laptop (2.7GHz dual-core i7, 8GB RAM) used for hosting the whole stack. While the machine can easily handle the load, I expect that at some point I'll replace it with something that is more suited for running 24x7 - I have some concerns about fire safety with the Macbook's built-in battery.  |
| [iPad mini (Gen 2, Gen 4)](https://www.apple.com/lae/ipad-mini/)                                                        | Wall Mounted control panels             |
| [Raspberry Pi](https://www.raspberrypi.org/) + [DSMR](https://www.home-assistant.io/components/dsmr/)           | Raspberry Pi connected to smart energy meter for energy monitoring.  |
| [Wemos D1](https://wiki.wemos.cc/products:d1:d1)                                | A simple custom-build sensor using a cheap Arduino compatible board and an ultrasonic sensor to measure the current height of my standing desk. This allows me to track how much time I've been standing during the day. |
| [Quooker](https://www.quooker.co.uk/) | Boiling water tap. Not a smart device, but still a very time-saving way to boil water for tea or cooking  |
 


## Software
| Software                                                                        | Description         |
| ------------------------------------------------------------------------------- | ------------------- |
| [Homeassistant](https://home-assistant.io/)       | Main home automation platform that integrates everything together.   |
| [Slack](https://slack.com/)               | Used for sending notifications when certain events occur around the house.     |
| SleepCycle  | TODO


## Supporting Software


| Software                                                                        | Description         |
| ------------------------------------------------------------------------------- | ------------------- |
| [Ubuntu 18.04](http://releases.ubuntu.com/18.04/)  | Operating System.  |
| [HADashboard](http://appdaemon.readthedocs.io/en/stable/DASHBOARD_INSTALL.html) | Part of [appdaemon](https://appdaemon.readthedocs.io/en/latest/) that allows for easy creation of dashboards for Home Assistant that are intended to be wall mounted (optimized for distance viewing).|
| [Docker](https://www.docker.com/)      | A good amount of software components run in containers, I use plain docker to manage them. I've considered using something like docker swarm or kubernetes for management/orchestration, but given that I only run containers on a single machine for now, I don't believe the overhead is worth it.                    |
| [ELK](https://www.elastic.co/elk-stack) | Log Aggregation, Search Indexing, web dashboard. Don't use ELK very excessively as it uses too much memory and CPU for my liking. I'm considering switching to [fleuntd](https://www.fluentd.org/) for the log aggregation part - but the truth is that I get by with just some CLI commands for the majority of what I need. Having a log aggregation stack installed is mostly for exploration purposes.    |
| [Grafana](https://grafana.com/)                      |  Visualization dashboard to display metrics stored in homeassistant and prometheus.                  |
| [Prometheus](https://prometheus.io/)   | Main monitoring platform that collects metrics on various components of my stack, and alerts when certain conditions are (not) met.   |
| [Alert Manager](https://prometheus.io/docs/alerting/alertmanager/) | Default alerting solution for prometheus. |
| [Node Exporter](https://github.com/prometheus/node_exporter) | Widely popular linux system data exporter for prometheus. |
| [Process Exporter](https://github.com/ncabatoff/process-exporter) | Prometheus exporter to collect metrics on specific linux processes |
| [Blackbox Exporter](https://github.com/prometheus/blackbox_exporter) | Prometheus exporter to collect metrics on external (blackbox) systems using network requests like ping, TCP connections, etc. |
| [Selenium](https://www.seleniumhq.org/)   | UI testing framework used as part of my sanity tests. Primarily used to periodically test that all dashboards are still loading correctly (if they're not, that's often an indicator of a bigger underlying issue). |
| [OpenWRT](https://openwrt.org/)               | Main AP/Router software. Not immediately related to home-automation but important supporting system. |
| [Ser2net](http://ser2net.sourceforge.net/) | Simple way to expose a serial port to the network. I use this to expose a serial stream coming from a Raspberry PI connected to my smart electricity meter to homeassistant.   |


# Retired

Other gear I have that is currently not (yet) integrated in the setup:

## Retired Hardware
| Hardware                                                                        | Notes         |
| ------------------------------------------------------------------------------- | ------------------- |
| [Elgato Eve Window sensor](https://www.evehome.com/en/eve-door-window)          | HomeKit only. Not currently using. |
| [Elgato Eve Power plug](https://www.evehome.com/en/eve-energy)                  | Homekit only. Reset wifi every night at 4AM to deal with linksys router firmware issue. Blue-tooth based. Ability to power cycle network gear even when whole network is down. |
| [Chromecast](https://store.google.com/product/chromecast)                       | We usually use our AppleTV(s) instead. |
| [Google Nest Home](https://store.google.com/product/google_nest_mini)           | We use our Echo Dot instead  |
| [Sonoff Basic R2](https://sonoff.tech/product/wifi-diy-smart-switches/basicr2)  | Wifi-enabled ESP8266 based remote relay  |
| [Shelly 1](https://shelly.cloud/products/shelly-1-smart-home-automation-relay/) | Wifi-enabled ESP8266 based remote relay  |
| [Deconz Conbee 2](https://phoscon.de/en/conbee) | Universal Zigbee gateway (can replace IKEA/Hue hubs), had some challenges getting this to work and haven't spend more time  |

## Retired Software
| Software                                                                        | Notes         |
| ------------------------------------------------------------------------------- | ------------------- |
| [node-sonos-http-api](https://github.com/jishi/node-sonos-http-api)             | HTTP API bridge for Sonos speakers. Filled some gaps in sonos features that HomeAssistant didn't support in the past.    |
| [SamTV](https://github.com/McKael/samtv) | Great little CLI tool I used to control my somewhat older Samsung SmartTV that isn't supported by homeassistant itself. No longer using it since we upgraded our TV to a newer model that is supported by homeassistant. |
| [Monit](https://mmonit.com/monit/) | When I started out, I used Monit for simple monitoring but I quickly required more elaborate monitoring capabilities. |
| [Sensu](https://sensu.io/) |  I migrated from Monit to Sensu for monitoring but over time that ended up consuming way too much CPU and memory which tended to slow my whole stack down. Currently on Prometheus. |
| [InfluxDB](https://docs.influxdata.com/influxdb)     | Time series database used to persistently store sensor and monitoring data. Stopped using it because Prometheus is already providing everything I needed and InfluxDB was adding too much overhead, contributing to high CPU utilization.  |

# Customized

On many occasions there's been a need to write custom scripts to enhance functionality or integrate certain systems together. The table below shows a few that I think are worth calling out - you'll probably find more when browsing the source code of this repository.

| Software                                                                        | Description         |
| ------------------------------------------------------------------------------- | ------------------- |
| [Sanity tests](https://github.com/jorisroovers/casa/tree/master/tests) | Small set of python tests that run every 5 min against the setup that check for some common problems and misconfigurations. These have been great to catch issues when I've made changes to the setup. |
 [prom2hass](roles/homeassistant/templates/prom2hass.py)  | Custom python script that fetches certain prometheus metrics or alerts and pushes them to homeassistant as sensors. Runs every 20 seconds. Allows for automatation of parts of the house based on monitoring conditions from prometheus. While there exist upstream supported integrations between homeassistant and prometheus, from my initial assessment they didn't   seem to be a good fit. |
| [Seshat](https://github.com/jorisroovers/seshat) | Simple set of script(s) in typescript that aggregate some metrics from InfluxDB into more interesting statistics that I can display in grafana. These run every minute via a cronjob. |
| [roofcam](https://github.com/jorisroovers/roofcam)                 |  Simple custom python program to determine whether my flat roof has any water on it (which means the draining pipes are clogged up). Uses very simple image manipulations on screenshots to determine this. At some point I'd like to do something more advanced with ML, but the current script already is ~85% accurate on test data. Don't always have this program running.                    |
| [Afvalwijzer](roles/homeassistant-sensors/templates/afvalwijzer/afvalwijzer.py) | Simple script to determine when the next trash pick date is (exposed as sensors in homeassistant). Scrapes the Dutch [mijnafvalwijzer.nl](https://www.mijnafvalwijzer.nl/) once every 24 hours to determine this. |
| [Backups](https://github.com/jorisroovers/casa/tree/master/roles/backups) | Set of scripts that do periodic backups of some personal data and copy the resulting tarballs over to a Samba/CIFS network share. Each backup script also has an accompanying monitoring script that periodically verifies whether the last backup was successful. |

## Home-assistant details

 Component                                                                        | Description         |
| ------------------------------------------------------------------------------- | ------------------- |
| [System Health](https://www.home-assistant.io/components/system_health/) | Expose Homeassistant system health via API |
| [Logger](https://www.home-assistant.io/integrations/logger/) | Configuration of home-assistant logging behavior |
| [Sun](https://www.home-assistant.io/integrations/sun) | Sun-based automation |
| [SSDP](https://www.home-assistant.io/integrations/ssdp) | Auto-discovery for samsung smart TV  |
| [Light Group](https://www.home-assistant.io/components/light.group/) | Combining multiple lights into groups |
| [Sensor - System monitor](https://www.home-assistant.io/integrations/systemmonitor/) | System monitoring (CPU, memory, etc) |
| [Sensor - Buienradar](https://www.home-assistant.io/components/sensor.buienradar/) | Local (Dutch) weather reporting and events |
| [Sensor - Commandline](https://www.home-assistant.io/integrations/command_line/) | Creating sensors from commandline output |
| [Sensor - Template](https://www.home-assistant.io/integrations/template/) | Transforming sensor data into formats that can be more easily be used in automations |
| [Binary Sensor - Workday](https://www.home-assistant.io/integrations/workday/) | Work vs. non-work day (weekend, holidays) influences automation  |
| [Binary Sensor - Template](https://www.home-assistant.io/integrations/binary_sensor.template/) | Transforming sensor data into binary formats that can be more easily be used in automations  |
| [Shell Command](https://www.home-assistant.io/integrations/shell_command/) | Running shell commands as part of automation |
| [Input Select](https://www.home-assistant.io/integrations/input_select/) | Selecting house and room modes, changing state will triggers scenes and automations. |
| [Input Boolean](https://www.home-assistant.io/integrations/input_boolean/) | Basic on-off switches that influence or trigger automation.  |
| | Device Control: Nest |


# Future Work
There's always more to automate!

- Siding curtains ([in-progress](projects/curtain-opener/README.md))
- ~~Automated window opening~~ (✅[done](https://jorisroovers.com/posts/window-opener))
- Window blinds (in addition to curtains, maybe?)
- Doorlocks
- Doorbell
- Sense Infuser? 
- Garden irrigation
- Improved presence detection
- Improved voice commands

# General Notes

- You might see some references to ```casa-data```: this is a private repo I maintain that contains the actual
data (encrypted) relevant to my home (usernames, passwords, secrets, IP addresses, etc). The roles and playbooks in this repo all
use dummy defaults.
- Since my family's mother tongue is Dutch, you'll see some Dutch language used here and there (mostly in the user-facing parts).
- I keep my setup disconnected from the Internet for security and privacy reasons. There are some exceptions (like some Nest devices I use), but those connect outward to the internet themselves - it's not possible to directly connect to any device from the Internet as everything runs in a private network.
- I have no idea how much time I've spend getting to this point, but I'm fairly certain it's a couple of hundreds of hours at least. Spread over about 4 years.
- I've never done a calculation of how much the current setup has cost me, but I'd roughly guess it's about ~3000 EUR. Note that it also highly depends on how you calculate things. Do you account for a (smart) TV? What about smart audio speakers? An old laptop that you had still lying around that you use as a server? Light bulbs you needed to buy anyways but you bought smartbulbs instead? etc.
- When I first started using home-assistant in 2016, things were in a very different state than they are today. This means I'd probably do things a bit differently if I'd start afresh today. So if you're looking at some code/config and wondering why I'm not using some out-of-the-box feature of home-assistant, changes are it didn't exist when I started out and I haven't come around to upgrading.
- If you're new to home-automation and want to do something similar to this, I recommend getting a [Raspberry Pi](https://www.raspberrypi.org/products/) (get the latest model with the most compute power) and installing [HomeAssistant](https://www.home-assistant.io/) on it. Then get yourself a set of [Philips Hue](https://www2.meethue.com/en-us) or [Ikea Tradfri](https://www.ikea.com/us/en/catalog/products/20411562/) smart light bulbs and start playing!

# Getting Started

**Ok, the title of this section is a lie. Like I've mentioned at the start of this README, I don't really expect this playbook to work for anyone but me. But if you ARE me, here's how you actually run this against your target hosts :-).**

Note: I'm currently using Ansible 2.9.4. The playbooks are not compatible with older Ansible versions.

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
ansible-playbook home.yml -i  ~/repos/casa-data/inventory/prod
```