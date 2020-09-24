// To install the Ultasonic library to work with a HC-SR04 ultrasonic depth sensor:
// Go to Sketch > Include Library > Manage Libraries...
// Then Install Ultrasonic by Erick Smoes (tested on v2.1.0)
// https://github.com/ErickSimoes/Ultrasonic
#include <Ultrasonic.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>

// --------------------------------------------------------------
// Read SECRET_WIFI_SSID and SECRET_WIFI_PASSWORD from secrets.h
// That file should look like:
// #define SECRET_WIFI_SSID "foo";
// #define SECRET_WIFI_PASSWORD "bar"
// #define SECRET_HTTP_HOST "10.0.0.1"
// #define SECRET_HTTP_PORT "80"
// Note that secrets.h is added to the .gitignore file, so that we
// don't accidentally upload sensitive data. Hence, you'll need to
// recreate the secrets.h file.
#include "secrets.h"

// --------------------------------------------------------------
// CONFIGURATION
// --------------------------------------------------------------
// WIFI
const char* WIFI_SSID              = SECRET_WIFI_SSID;
const char* WIFI_PASSWORD          = SECRET_WIFI_PASSWORD;
const int   WIFI_MAX_WAIT_ATTEMPTS = 20;
const int   WIFI_BACKOFF_MSEC      = 5000;
const int   WIFI_STATUS_LED_PIN    = D6;  // LED that is used to convey wifi connectivity status (set to -1 to skip);
// HTTP
String      HTTP_HOST              = SECRET_HTTP_HOST;
const int   HTTP_PORT              = SECRET_HTTP_PORT;
const char* HTTP_USER              = SECRET_HTTP_USER;
const char* HTTP_PASSWORD          = SECRET_HTTP_PASSWORD;
String      HTTP_URI               = "/sensors/deskheight"; // leading slash is required

// MISC
const int   LOOP_INTERVAL_MSEC     = 5000; // How often do we measure desk height
const int   HTTP_LED_SUCCESS_PIN   = D7;   // LED pin that is used to blink on http success
const int   HTTP_LED_ERROR_PIN     = D10;  // LED pin that is used to blink on http success

// --------------------------------------------------------------

// With Wemos D1, use the provided constants, like D3 (and not 3) because the actual numbers are different
// Wire D3 up to Trig, D4 up to Ping on the HC-SR04 module
Ultrasonic ultrasonic(D3, D4);

// --------------------------------------------------------------
// WIFI Convenience functions

void ensureWifiConnection(){
  if (WiFi.status() == WL_CONNECTED){
    return;
  }
  Serial.println("Wifi connection lost. Reconnecting...");
  connectToWifi();
}

void connectToWifi(){
  if (WIFI_STATUS_LED_PIN > 0){
    digitalWrite(WIFI_STATUS_LED_PIN, LOW);
  }
  Serial.printf("Connecting to %s\n", WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  int attempts = 0;
  int lastStatusLEDState = LOW;

  while (WiFi.status() != WL_CONNECTED) {
    // If we have a status LED, then blink it
    if (WIFI_STATUS_LED_PIN > 0){
      if (lastStatusLEDState == LOW){
          digitalWrite(WIFI_STATUS_LED_PIN, HIGH);
          lastStatusLEDState = HIGH;
      } else {
          digitalWrite(WIFI_STATUS_LED_PIN, LOW);
          lastStatusLEDState = LOW;
      }
    }

    delay(500);
    Serial.print(".");
    attempts++;
    if (attempts == WIFI_MAX_WAIT_ATTEMPTS) {
        Serial.println();
        Serial.printf("Wifi not connected after %d attempts.\n", attempts);
        Serial.printf("Backing off for %d msec...\n", WIFI_BACKOFF_MSEC);

        if (WIFI_STATUS_LED_PIN > 0){
          digitalWrite(WIFI_STATUS_LED_PIN, LOW);
        }
        delay(WIFI_BACKOFF_MSEC);
        Serial.println("Let's try this again...");
        attempts = 0;
    }
  }

  if (WIFI_STATUS_LED_PIN > 0){
    digitalWrite(WIFI_STATUS_LED_PIN, HIGH);
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

// --------------------------------------------------------------
// The actual party starts here

void setup(){
  Serial.begin(115200);
  Serial.println("Starting...");
  pinMode(WIFI_STATUS_LED_PIN, OUTPUT);
  pinMode(HTTP_LED_SUCCESS_PIN, OUTPUT);
  pinMode(HTTP_LED_ERROR_PIN, OUTPUT);
  connectToWifi();
}


void loop(){
    ensureWifiConnection();

    // Determine desk height
    // We do very basic signal smoothing by measuring three times and taking the max
    const int deskheightRaw1 = ultrasonic.distanceRead();
    delay(150);
    const int deskheightRaw2 = ultrasonic.distanceRead();
    delay(150);
    const int deskheightRaw3 = ultrasonic.distanceRead();
    
    int deskheight = _max(deskheightRaw1, deskheightRaw2); // Use _max() instead of max(): https://github.com/esp8266/Arduino/issues/2073
    deskheight = _max(deskheight, deskheightRaw3);

    Serial.printf("Desk height: %d CM (raw1: %d CM, raw2: %d CM, raw3: %d CM)\n", deskheight, deskheightRaw1, deskheightRaw2, deskheightRaw3) ;

    Serial.printf("Sending desk height of '%d' to %s:%i%s\n", deskheight, HTTP_HOST.c_str(), HTTP_PORT, HTTP_URI.c_str());

    // Create http client
    // https://github.com/esp8266/Arduino/blob/master/libraries/ESP8266HTTPClient/
    HTTPClient http;
    http.begin(HTTP_HOST, HTTP_PORT, HTTP_URI);
    http.setAuthorization(HTTP_USER, HTTP_PASSWORD);

    http.setUserAgent("Deskheight sensor - Wemos D1");
    http.addHeader("content-type", "application/json");

    // '{"value": "<deskheight>", "homeassistant_sensor": { "name": "deskheight", "state": "<deskheight>", "attributes": { "friendly_name": "Desk Height", "unit_of_measurement": "cm" }}}'
    String payload = String("{ \"value\": \"") + deskheight + String("\", \"homeassistant_sensor\": { \"name\": \"deskheight\",\"state\": \"") + deskheight + String("\", \"attributes\": { \"friendly_name\": \"Desk Height\", \"unit_of_measurement\": \"cm\" }}}");

    int httpCode = http.POST(payload);
    int statusLed = HTTP_LED_ERROR_PIN;

    // httpCode will be negative on error
    if(httpCode > 0) {
        // HTTP header has been send and Server response header has been handled
        Serial.printf("[HTTP] POST... code: %d\n", httpCode);

        // file found at server
        if(httpCode == HTTP_CODE_OK) {
            String payload = http.getString();
            Serial.println(payload);
            statusLed = HTTP_LED_SUCCESS_PIN;
        }
    } else {
        Serial.printf("[HTTP] POST... failed, error: %s\n", http.errorToString(httpCode).c_str());
    }

    http.end();

    Serial.printf("Next loop in %d msec \n", LOOP_INTERVAL_MSEC);

    // Blink led
    digitalWrite(statusLed, HIGH);
    delay(500);
    digitalWrite(statusLed, LOW);

    delay(LOOP_INTERVAL_MSEC);

}

