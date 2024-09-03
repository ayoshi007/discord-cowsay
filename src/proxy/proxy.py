from enum import auto, IntEnum
import os
import json
import boto3
from nacl.signing import VerifyKey
from nacl.exceptions import BadSignatureError


class InteractionType(IntEnum):
    PING = 1
    APPLICATION_COMMAND = auto()
    MESSAGE_COMPONENT = auto()
    APPLICATION_COMMAND_AUTOCOMPLETE = auto()
    MODAL_SUBMIT = auto()


class InteractionCallbackType(IntEnum):
    PONG = 1
    CHANNEL_MESSAGE_WITH_SOURCE = 4
    DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE = 5


PUBLIC_KEY = os.environ["DISCORD_PUBLIC_TOKEN"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]
SIGNATURE_HEADER = "x-signature-ed25519"
SIGNATURE_TIMESTAMP = "x-signature-timestamp"

verify_key = VerifyKey(bytes.fromhex(PUBLIC_KEY))
sns_client = boto3.client("sns")

def _validate_request_headers(signature, body, timestamp):
    try:
        verify_key.verify(f"{timestamp}{body}".encode(),
                          bytes.fromhex(signature))
    except BadSignatureError:
        return {
            "isBase64Encoded": False,
            "statusCode": 401,
            "headers": {"content-type": "application/json"},
            "body": "Invalid request signature"
        }


def handler(event, context):
    signature = event["headers"].get(SIGNATURE_HEADER)
    timestamp = event["headers"].get(SIGNATURE_TIMESTAMP)
    body = event.get("body")

    validation = _validate_request_headers(signature, body, timestamp)
    if validation:
        return validation

    interaction = json.loads(body)
    interaction_type = interaction.get("type")
    response_json = {}
    print(interaction)
    if interaction_type == InteractionType.PING:
        response_json["type"] = InteractionCallbackType.PONG
    elif interaction_type == InteractionType.APPLICATION_COMMAND:
        application_id = interaction["application_id"]
        interaction_token = interaction["token"]
        interaction_data = interaction["data"]
        try:
            sns_client.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=json.dumps({
                    "application_id": application_id,
                    "interaction_token": interaction_token,
                    "options": interaction_data.get("options"),
                }),
                MessageAttributes={
                    "command": {
                        "DataType": "String",
                        "StringValue": interaction_data["name"]
                    },
                }
            )
        except Exception as e:
            print(e)
        response_json["type"] = InteractionCallbackType.DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE
    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(response_json)
    }
