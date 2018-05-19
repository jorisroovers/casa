import pytest
import os
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import logging

# Turn off logging for selenium:
# https://stackoverflow.com/questions/9226519/turning-off-logging-in-selenium-from-python
from selenium.webdriver.remote.remote_connection import LOGGER
LOGGER.setLevel(logging.WARNING)


def pytest_addoption(parser):
    parser.addoption("--hadashboard-url", action="store", required=True, help="URL of HADashboard to test")
    parser.addoption("--homeassistant-url", action="store", required=True, help="URL of homeassistant to test")
    parser.addoption("--homeassistant-password", action="store", required=True, help="Password of homeassistant to test")
    parser.addoption("--chrome-driver-path", action="store", default=os.path.expanduser("~/chromedriver"),
                     help="Path to Selenium chrome Driver path")


@pytest.fixture(scope="session")
def driver(request):
    options = Options()
    options.add_argument('--headless')
    driver_path = os.path.abspath(request.config.getoption("--chrome-driver-path"))
    driver = webdriver.Chrome(driver_path, chrome_options=options)
    driver.set_page_load_timeout(5)

    # Make sure we call driver.quit() at the end to clean up to chromedriver process
    # Note: you need to call driver.quit() and NOT driver.close() as this will only close the Chrome window
    def quit_driver():
        driver.quit()
    request.addfinalizer(quit_driver)
    return driver


@pytest.fixture(scope="module")
def hadashboard_url(request):
    return request.config.getoption("--hadashboard-url")

@pytest.fixture(scope="module")
def homeassistant_url(request):
    return request.config.getoption("--homeassistant-url")

@pytest.fixture(scope="module")
def homeassistant_password(request):
    return request.config.getoption("--homeassistant-password")
