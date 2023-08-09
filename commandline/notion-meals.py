import http.client
import json
from datetime import datetime, timedelta

import yaml

# Load the secrets from the secrets.yaml file
with open("secrets.yaml", "r") as file:
    secrets = yaml.safe_load(file)
    NOTION_API_KEY = secrets["notion_api_key"]
    DATABASE_ID = secrets["notion_meals_database_id"]

# Set up the connection and request headers
conn = http.client.HTTPSConnection("api.notion.com")
headers = {
    "Authorization": f"Bearer {NOTION_API_KEY}",
    "Notion-Version": "2022-02-22",
    "Content-Type": "application/json",
}

# Construct the filter for the date range
start_date = (datetime.today() - timedelta(days=3)).date().isoformat()
end_date = (datetime.today() + timedelta(days=7)).date().isoformat()
filter_body = json.dumps({
    "filter": {
        "property": "Date",
        "date": {
            "after": start_date,
            "before": end_date
        }
    }
})

# Make a POST request to fetch the database
conn.request("POST", f"/v1/databases/{DATABASE_ID}/query", body=filter_body, headers=headers)
response = conn.getresponse()

try:
    # Parse output
    if response.status == 200:
        data = json.loads(response.read())
        meals = {}
        for item in data['results']:
            # print(json.dumps(item, indent=2)) # Printing all output
            name_value = item['properties']['Name']['title'][0]['plain_text']
            date_value = item['properties']['Date']['date']['start']
            meals[date_value] = name_value
        # Sort by date
        sorted_meals = json.dumps(dict(sorted(meals.items())))
        print(sorted_meals)
    else:
        print(f"Failed to fetch database: {response.read().decode()}")
finally:
    conn.close()

