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

def delete_commands() -> int:
    response = requests.get(url, headers=headers)
    command_list = response.json()
    print(f"Attempting to delete {len(command_list)} existing commands")
    for command in command_list:
        delete_url = f"{url}/{command['id']}"
        response = requests.delete(delete_url, headers=headers)
        response.raise_for_status()
        print(f"{response.status_code}: Deleted command {command['name']}")
    print(f"Successfully deleted {len(command_list)} commands")

def register(commands):
    print(f"Attempting to register {len(commands)} commands...")
    for command in commands:
        response = requests.post(url, headers=headers, json=command)
        response.raise_for_status()
        print(f"{response.status_code}: Registered command {command['name']}")
    print(f"Successfully registered {len(commands)} commands")
    
def run(json_file):
    if not os.path.exists(json_file):
        raise FileNotFoundError(f"Could not find {json_file}")
    delete_commands()
    with open(json_file) as f:
        commands = json.load(f)
    register(commands)
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog="Discord register", description="A registration script for Discord global or guild commands")
    parser.add_argument("json", help="Path to JSON file of commands to register")
    parsed = parser.parse_args(sys.argv[1:])
    run(parsed.json)
