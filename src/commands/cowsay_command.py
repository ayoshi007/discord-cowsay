import json
import requests
import cowsay

callback_url = "https://discord.com/api/v10/webhooks/{}/{}"


def handler(event, _):
    records = event["Records"]
    data = json.loads(records[0]["Sns"]["Message"])
    application_id = data["application_id"]
    interaction_token = data["interaction_token"]
    url = callback_url.format(application_id, interaction_token)
    try:
        options = data.get("options", [])
        data = {
            "text": "moo",
            "character": "cow"
        }
        for option in options:
            data[option["name"]] = option["value"]
        cowsay_response = cowsay.get_output_string(
            data["character"], data["text"]
        )
    except Exception as e:
        requests.post(url, json={"content": "Command failed"})
        raise e

    r = requests.post(
        url,
        json={
            "content": f"```{cowsay_response}```"
        }
    )
    r.raise_for_status()
    print(r.json())
