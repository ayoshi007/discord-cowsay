import os
import json
import uuid
import boto3
from boto3.dynamodb.conditions import Key, Attr
import requests
import cowsay

callback_url = "https://discord.com/api/v10/webhooks/{}/{}"

DYNAMODB_TABLE_NAME = os.environ["DYNAMODB_TABLE_NAME"]
DYNAMODB_TABLE_ID = os.environ["DYNAMODB_TABLE_ID"]

def get_quote() -> tuple[str, str]:
    # fetch quote from DynamoDB
    dynamodb_resource = boto3.resource("dynamodb")
    table = dynamodb_resource.Table(DYNAMODB_TABLE_NAME)
    id = str(uuid.uuid4())
    response = table.scan(
        Limit=1,
        ExclusiveStartKey={
            DYNAMODB_TABLE_ID: id
        },
        ProjectionExpression="Quote, Author",
    )
    return response["Items"][0]["Author"], response["Items"][0]["Quote"]

def handler(event, _):
    records = event["Records"]
    data = json.loads(records[0]["Sns"]["Message"])
    application_id = data["application_id"]
    interaction_token = data["interaction_token"]
    url = callback_url.format(application_id, interaction_token)
    try:
        options = data.get("options", [])
        author, quote = get_quote()
        data = {
            "text": f"{quote}\n {author}",
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
