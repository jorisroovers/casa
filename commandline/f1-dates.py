import http.client
import xml.etree.ElementTree as ET
import json

host = "ergast.com"
path = "/api/f1/current/next"
connection = http.client.HTTPConnection(host)
connection.request("GET", path)
response = connection.getresponse()

if response.status == 200:
    xml_data = response.read()
    root = ET.fromstring(xml_data)
    ns = {"ns": "http://ergast.com/mrd/1.5"}

    # Extract the required information
    grand_prix_name = root.find(".//ns:RaceName", ns).text
    grand_prix_date = (
        root.find(".//ns:Date", ns).text + " " + root.find(".//ns:Time", ns).text
    )
    circuit_name = root.find(".//ns:Circuit/ns:CircuitName", ns).text
    qualifying_date = (
        root.find(".//ns:Qualifying/ns:Date", ns).text
        + " "
        + root.find(".//ns:Qualifying/ns:Time", ns).text
    )
    first_practice_date = (
        root.find(".//ns:FirstPractice/ns:Date", ns).text
        + " "
        + root.find(".//ns:FirstPractice/ns:Time", ns).text
    )
    second_practice_date = (
        root.find(".//ns:SecondPractice/ns:Date", ns).text
        + " "
        + root.find(".//ns:SecondPractice/ns:Time", ns).text
    )
    third_practice_date = (
        root.find(".//ns:ThirdPractice/ns:Date", ns).text
        + " "
        + root.find(".//ns:ThirdPractice/ns:Time", ns).text
    )

    # Create a JSON object
    result_json = {
        "dates": {
            "grand_prix_name": grand_prix_name,
            "grand_prix_date": grand_prix_date,
            "circuit_name": circuit_name,
            "qualifying_date": qualifying_date,
            "first_practice_date": first_practice_date,
            "second_practice_date": second_practice_date,
            "third_practice_date": third_practice_date,
        }
    }

    print(json.dumps(result_json))
else:
    print("Failed to fetch data. Status code:", response.status)
