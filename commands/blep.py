import json
import requests

callback_url = "https://discord.com/api/v10/webhooks/{}/{}"

def handler(event, context):
    records = event["Records"]
    print(records)
    data = json.loads(records[0]["Sns"]["Message"])
    application_id = data["application_id"]
    interaction_token = data["interaction_token"]
    options = data.get("options", [])
    option_values = [option.get("value") for option in options]
    url = callback_url.format(application_id, interaction_token)
    r = requests.post(
        url,
        json={
            "content": f"blep {option_values}"
        }
    )
    r.raise_for_status()
    print(r.json())
    