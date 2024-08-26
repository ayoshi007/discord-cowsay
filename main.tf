terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.64.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.5.0"
    }
  }
}

provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["$HOME/.aws/credentials"]
}

module "common" {
    source = "./terraform/common"
    layer_source_dir = "${path.module}/venv/layer"
}

module "proxy" {
    source = "./terraform/proxy"
    source_dir = "${path.module}/proxy"
    handler_function = "proxy.handler"

    discord_public_token = var.discord_public_token
    invoke_command_topic_arn = module.common.invoke_command_sns_arn
    layer_arn = module.common.lambda_layer_arn
    sns_publish_policy_arn = module.common.sns_publish_policy_arn
}

module "blep_command" {
    command_name = "blep"
    source = "./terraform/command"
    source_file = "${path.module}/commands/blep.py"
    handler_function = "blep.handler"

    discord_public_token = var.discord_public_token
    invoke_command_topic_arn = module.common.invoke_command_sns_arn
    layer_arn = module.common.lambda_layer_arn
    iam_role_arn = module.common.command_role_arn
}

module "blop_command" {
    command_name = "blop"
    source = "./terraform/command"
    source_file = "${path.module}/commands/blop.py"
    handler_function = "blop.handler"

    discord_public_token = var.discord_public_token
    invoke_command_topic_arn = module.common.invoke_command_sns_arn
    layer_arn = module.common.lambda_layer_arn
    iam_role_arn = module.common.command_role_arn
}
