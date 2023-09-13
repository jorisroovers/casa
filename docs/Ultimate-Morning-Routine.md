# Creating the Ultimate Morning Routine

Below you can find pointers to all integrations, software and hardware mentioned from my conference talk **Creating the Ultimate Morning Routine**, which was presented at the home-assistant conference on 13 December 2020.

- [Youtube recording: Creating the Ultimate Morning Routine](https://www.youtube.com/watch?v=6NifGWGOfSk)
- [Slide Deck: Creating the Ultimate Morning Routine](/docs/Creating%20the%20Ultimate%20Morning%20Routine%20-%20Joris%20Roovers.pdf)
- General
  - [`morning_routine.yaml`](/roles/homeassistant/templates/automations/morning_routine.yaml) contains a good chunk of the relevant automations, others are spread around in other files in the [`automations`](/roles/homeassistant/templates/automations/) directory.
- Bedroom
    - [SleepCycle intelligent alarm app](https://www.sleepcycle.com/)
    - [Philips Hue lightbulbs](https://www.philips-hue.com/)
    - [Window Opener Project details](https://jorisroovers.com/posts/window-opener)
- Bathroom
    - [Ikea TRÅDFRI smart lights](https://www.ikea.com/us/en/cat/smart-lighting-36812/)
    - [Sonos smartspeakers](http://sonos.com/)
    - Smartplug: so many options. [Don't get TP Link (which I use)](https://alerts.home-assistant.io/#tplink.markdown)
    - [Mirror heating pad](https://www.amazon.com/WarmlyYours-Rectangle-Defogger-Self-Adhesive-Hardwired/dp/B0031TUK70) (not the one I got)
- Hallway
    - [My House mode input_select automations](https://github.com/jorisroovers/casa/blob/master/roles/homeassistant/templates/automations/house_mode.yaml)
    - [Smart curtain details](https://github.com/jorisroovers/casa/tree/master/projects/curtain-opener)
    - [Nest Cameras](https://store.google.com/us/magazine/compare_cameras)
    - [Flux light temperature variation](https://www.home-assistant.io/integrations/flux/)
        - I don't use this myself, as I wanted more control than what this integration provides
    - [Appdaemon interface for wall-mounted tablets](https://appdaemon.readthedocs.io/en/latest/DASHBOARD_INSTALL.html)
- Living Room
    - [Nest Climate Control](https://store.google.com/us/product/nest_learning_thermostat_3rd_gen)
    - [Raspberry Pi](https://www.raspberrypi.org/products/)
    - [Custom API/script to control TV through HDMI CEC](https://github.com/jorisroovers/casa/blob/master/roles/tv/templates/api.py)
- Kitchen
    - [Quooker hot water tap](https://www.quooker.com/)
    - Alternatives: [Grohe RED hot water tap](https://www.grohe.co.uk/en_gb/kitchen-collection/grohe-red.html)
- Office
    - [Homeassistant Workday Sensor](https://www.home-assistant.io/integrations/workday/)
    - [Homeassistant Mac companion App](https://www.home-assistant.io/blog/2020/09/18/mac-companion/)
