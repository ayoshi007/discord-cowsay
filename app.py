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


PUBLIC_KEY = os.environ["DISCORD_PUBLIC_TOKEN"]
SIGNATURE_HEADER = "x-signature-ed25519"
SIGNATURE_TIMESTAMP = "x-signature-timestamp"

verify_key = VerifyKey(bytes.fromhex(PUBLIC_KEY))


def _validate_request_headers(signature, body, timestamp):
    try:
        verify_key.verify(f"{timestamp}{body}".encode(),
                          bytes.fromhex(signature))
    except BadSignatureError:
        raise Exception("[UNAUTHORIZED] Invalid request signature")


def lambda_handler(event):
    signature = event["header"].get(SIGNATURE_HEADER)
    timestamp = event["header"].get(SIGNATURE_TIMESTAMP)
    body = event.get("body")

    _validate_request_headers(signature, body, timestamp)

    interaction = json.loads(body)
    response_json = {}
    if interaction.get("type") == InteractionType.PING:
        response_json["type"] = InteractionCallbackType.PONG

    return response_json
