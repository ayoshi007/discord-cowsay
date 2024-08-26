import os
import requests
from dotenv import load_dotenv

load_dotenv()

APP_ID = os.environ["DISCORD_APP_ID"]
BOT_TOKEN = os.environ["DISCORD_BOT_TOKEN"]
GUILD_ID = os.environ.get("DISCORD_GUILD_ID", None)

global_cmd_update_url = f"https://discord.com/api/v10/applications/{APP_ID}/commands"
guild_cmd_update_url = f"https://discord.com/api/v10/applications/{APP_ID}/guilds/{GUILD_ID}/commands"
headers = {
    "Authorization": f"Bot {BOT_TOKEN}"
}

jsons = [
    {
        "name": "blep",
        "type": 1,
        "description": "test slash command",
        "options": [
            {
                "name": "animal",
                "description": "animal type",
                "type": 3,
                "required": True,
                "choices": [
                    {
                        "name": "Dog",
                        "value": "doggo",
                    },
                    {
                        "name": "Cat",
                        "value": "catto",
                    },
                    {
                        "name": "Bird",
                        "value": "birdo",
                    },
                ]
            },
            {
                "name": "sound",
                "description": "Respond with an animal sound",
                "type": 5,
                "required": False,
            },
        ],
    },
    {
        "name": "blop",
        "type": 1,
        "description": "test slash command",
        "options": [
            {
                "name": "animal",
                "description": "animal type",
                "type": 3,
                "required": True,
                "choices": [
                    {
                        "name": "Dog",
                        "value": "doggo",
                    },
                    {
                        "name": "Cat",
                        "value": "catto",
                    },
                    {
                        "name": "Bird",
                        "value": "birdo",
                    },
                ]
            },
            {
                "name": "sound",
                "description": "Respond with an animal sound",
                "type": 5,
                "required": False,
            },
        ],
    },
]
url = guild_cmd_update_url if GUILD_ID else global_cmd_update_url
for json in jsons:
    response = requests.post(url, headers=headers, json=json)
    response.raise_for_status()
    print(response.status_code)
    print(response.json())
