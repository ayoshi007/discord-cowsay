from enum import auto, IntEnum
import os
import json
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


PUBLIC_KEY = os.environ["DISCORD_PUBLIC_TOKEN"]
SIGNATURE_HEADER = "x-signature-ed25519"
SIGNATURE_TIMESTAMP = "x-signature-timestamp"

verify_key = VerifyKey(bytes.fromhex(PUBLIC_KEY))


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


def handle_command(interaction):
    print(interaction.get("name"))
    print(interaction.get("type"))
    print(interaction.get("data"))
    return {
        "type": InteractionCallbackType.CHANNEL_MESSAGE_WITH_SOURCE,
        "data": {
            "content": "Hello from Lambda",
        }
    }
    


def lambda_handler(event, context):
    signature = event["headers"].get(SIGNATURE_HEADER)
    timestamp = event["headers"].get(SIGNATURE_TIMESTAMP)
    body = event.get("body")

    validation = _validate_request_headers(signature, body, timestamp)
    if validation:
        return validation

    interaction = json.loads(body)
    interaction_type = interaction.get("type")
    response_json = {}
    if interaction_type == InteractionType.PING:
        response_json["type"] = InteractionCallbackType.PONG
    elif interaction_type == InteractionType.APPLICATION_COMMAND:
        response_json = handle_command(interaction)

    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(response_json)
    }
