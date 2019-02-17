import logging
import pytest

import requests

LOG = logging.getLogger()


def test_light_groups(homeassistant_url, homeassistant_password):
    """ Test that light groups are working """

    headers = {'x-ha-access': homeassistant_password, 'content-type': 'application/json'}
    response = requests.get(f"{homeassistant_url}/api/states/light.office", headers=headers)
    original_light_state = response.json()['state']

    # Turn the light on, off, back to original state and check whether all lights in the group have the same state
    for state in ["on", "off", original_light_state]:

        requests.post(f"{homeassistant_url}/api/services/light/turn_{state}", json={"entity_id": "light.office"})

        lamp_entities = ['light.office_lamp_1', 'light.office_lamp_3', 'light.office_lamp_3']
        for lamp_entity in lamp_entities:
            lamp_entity_url = f"{homeassistant_url}/api/states/{lamp_entity}"
            response = requests.get(lamp_entity_url, headers=headers)
            assert response.json()['state'] == state


@pytest.mark.sanity
def test_automations_on(hass_states):
    """ Test that all automations are enabled """

    for item in hass_states:
        if item['entity_id'].startswith("automation."):
            assert item['state'] == "on"


@pytest.mark.sanity
def test_light_naming_convention(hass_states):
    """ Test that all light friendly names match onto their entity ids.
        We enforce this convention in casa as mismatches are often a cause of the wrong
        lights being used in scenes and automations. """

    for item in hass_states:
        if item['entity_id'].startswith("light."):
            expected_entity_id = "light." + item['attributes']['friendly_name'].lower().replace(" ", "_")
            assert item['entity_id'] == expected_entity_id


@pytest.mark.sanity
def test_group_entities(hass_states):
    """ Tests that all entities in all groups actually exist, this catches group misconfigurations. """

    all_entity_ids = [i['entity_id'] for i in hass_states]
    for item in hass_states:
        if item['entity_id'].startswith("group."):
            for member_entity_id in item['attributes']['entity_id']:
                assert member_entity_id in all_entity_ids
