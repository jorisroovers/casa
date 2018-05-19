import logging
import requests

LOG = logging.getLogger()


def test_light_groups(driver, homeassistant_url, homeassistant_password):
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
