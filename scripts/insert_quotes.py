import os
import sys
import uuid
import json
import argparse
import boto3
from dotenv import load_dotenv

load_dotenv()


def run(json_file: str):
    if not os.path.exists(json_file):
        raise FileNotFoundError(f"Could not find file {json_file}")
    with open(json_file) as f:
        items = json.load(f)
    json_payloads = []
    for item in items:
        quote = item["q"]
        author = item["a"]
        id = str(uuid.uuid4())
        json_payloads.append({
            "PutRequest": {
                "Item": {
                    "Author": {
                        "S": author,
                    },
                    "Quote": {
                        "S": quote,
                    },
                    "Id": {
                        "S": id,
                    },
                }
            }
        })
    dynamodb_client = boto3.client("dynamodb")
    for i in range(0, len(json_payloads), 25):
        payload = json_payloads[i:i + 25]
        request = {
            "CowQuotes": payload
        }
        response = dynamodb_client.batch_write_item(RequestItems=request)
        print(response)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="DynamoDB put items",
        description="A script for putting new items into the bot's DynamoDB table"
    )
    parser.add_argument(
        "json", help="Path to JSON file with items to put")
    parsed = parser.parse_args(sys.argv[1:])
    run(parsed.json)
