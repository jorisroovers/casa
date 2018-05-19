import logging

LOG = logging.getLogger()


def test_entity_not_found(driver, hadashboard_url):
    # Find all dashboards:
    driver.get(hadashboard_url)
    links = driver.find_elements_by_css_selector("#dashes a")
    URLs = [link.get_attribute("href") for link in links]

    # Assert that no empty entities are found
    no_errors = True
    for url in URLs:
        url = f"{url}?skin=casa"
        LOG.info(f"Testing {url}")
        driver.get(url)
        els = driver.find_elements_by_xpath("//*[contains(text(), 'entity not found')]")
        if len(els) == 0:
            LOG.info(f"PASSED")
        for el in els:
            LOG.error(f"{el.text}")
            LOG.error(f"NOT PASSED")
            no_errors = False

    assert no_errors == True
