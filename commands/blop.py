import requests

callback_url = "https://discord.com/api/v10/interactions/{}/{}/callback"

def handler(event, context):
    records = event["Records"]
    print(records)
    data = json.loads(records[0]["Sns"]["Message"])
    interaction_id = data["interaction_id"]
    interaction_token = data["interaction_token"]
    options = data.get("options", [])
    option_values = [option.get("value") for option in options]
    url = callback_url.format(interaction_id, interaction_token)
    r = requests.post(url, json={
        "type": 4,
        "data": {
            "content": f"blep {option_values}"
        }
    })
    r.raise_for_status()
    print(r.json())
    