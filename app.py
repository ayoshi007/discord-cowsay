from enum import auto, IntEnum
import os
from flask import Flask, make_response, request
from nacl.signing import VerifyKey
from nacl.exceptions import BadSignatureError
from dotenv import load_dotenv

load_dotenv()
app = Flask(__name__)


class InteractionType(IntEnum):
    PING = 1
    APPLICATION_COMMAND = auto()
    MESSAGE_COMPONENT = auto()
    APPLICATION_COMMAND_AUTOCOMPLETE = auto()
    MODAL_SUBMIT = auto()


class InteractionCallbackType(IntEnum):
    PONG = 1


PUBLIC_KEY = os.environ["DISCORD_PUBLIC_TOKEN"]
SIGNATURE_HEADER = "X-Signature-Ed25519"
SIGNATURE_TIMESTAMP = "X-Signature-Timestamp"

verify_key = VerifyKey(bytes.fromhex(PUBLIC_KEY))


def _validate_request_headers(signature, body, timestamp) -> bool:
    retval = True
    try:
        verify_key.verify(f"{timestamp}{body}".encode(),
                          bytes.fromhex(signature))
    except BadSignatureError:
        retval = False
    return retval


@app.post("/")
def root():
    signature = request.headers[SIGNATURE_HEADER]
    timestamp = request.headers[SIGNATURE_TIMESTAMP]
    body = request.data.decode("utf-8")
    if not _validate_request_headers(signature, body, timestamp):
        return make_response("Invalid request signature", 401)

    interaction = request.get_json()
    response_json = {}
    if interaction["type"] == InteractionType.PING:
        response_json["type"] = InteractionCallbackType.PONG

    return make_response(response_json, 200)
