import sys
import os
import json
import argparse
import requests
from dotenv import load_dotenv

load_dotenv()
APP_ID = os.environ["DISCORD_APP_ID"]
BOT_TOKEN = os.environ["DISCORD_BOT_TOKEN"]
GUILD_ID = os.environ.get("DISCORD_GUILD_ID", None)
url = f"https://discord.com/api/v10/applications/{APP_ID}/guilds/{GUILD_ID}/commands" if GUILD_ID else f"https://discord.com/api/v10/applications/{APP_ID}/commands"
headers = {
    "Authorization": f"Bot {BOT_TOKEN}"
}

def delete_commands():
    print("Attempting to delete all existing commands")
    response = requests.get(url, headers=headers)
    command_list = response.json()
    for command in command_list:
        delete_url = f"{url}/{command['id']}"
        response = requests.delete(url)
        response.raise_for_status()
        print(f"{response.status_code}: Deleted command {command['name']}")
    print(f"Successfully deleted {len(command_list)} commands")

def register(json_file):
    command_list = json.load(json_file)
    print(f"Attempting to register {len(command_list)} commands...")
    for command in command_list:
        response = requests.post(url, headers=headers, json=command)
        response.raise_for_status()
        print(f"{response.status_code}: Registered command {command['name']}")
    print(f"Successfully registered {len(command_list)} commands")
    

if __name__ == "__main__":
    JSON_ARG = "json"
    args = sys.argv[1:]
    parser = argparse.ArgumentParser()
    parser.add_argument(JSON_ARG, required=True, help="Path to JSON file of commands to register")
    parsed = parser.parse_args(args)
    delete_commands()
    register(parsed[JSON_ARG])
