# Discord Cowsay Bot
A rather messy implementation for a Discord bot that responds to user messages with Cowsay ASCII art.

Uses Terraform to set up AWS Lambda, DynamoDB, SNS, and supporting architecture and uses Discord's interactions endpoint.

This is not really meant to be used, but is more of a learning project for me.

Supported commands:
- `/cowsay <text> [<character>]` - displays Cowsay output for the inputted text in Discord block text format (default character is cow)
- `/cowquote [<character>]` - displays Cowsay output with a randomly queried quote (default character is cow)

