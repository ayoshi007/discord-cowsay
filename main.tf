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
  source           = "./terraform/common"

  layer_source_dir = "${path.module}/venv/layer"
}

module "proxy" {
  source           = "./terraform/proxy"

  source_dir       = "${path.module}/src/proxy"
  handler_function = "proxy.handler"

  discord_public_token     = var.discord_public_token
  invoke_command_topic_arn = module.common.invoke_command_sns_arn
  layer_arn                = module.common.lambda_layer_arn
  sns_publish_policy_arn   = module.common.sns_publish_policy_arn
}

module "cowsay_command" {
  source           = "./terraform/command"

  command_name     = "cowsay"
  source_file      = "${path.module}/src/commands/cowsay_command.py"
  handler_function = "cowsay_command.handler"

  invoke_command_topic_arn = module.common.invoke_command_sns_arn
  layer_arn                = module.common.lambda_layer_arn
}

module "cowquote_command" {
  source           = "./terraform/command"

  command_name     = "cowquote"
  source_file      = "${path.module}/src/commands/cowquote_command.py"
  handler_function = "cowquote_command.handler"

  invoke_command_topic_arn = module.common.invoke_command_sns_arn
  layer_arn                = module.common.lambda_layer_arn
}


module "cowquote_infra" {
  source = "./terraform/cowquote"

  command_lambda_arn = module.cowquote_command.function_arn
  command_lambda_name = module.cowquote_command.function_name
  command_lambda_role_arn = module.cowquote_command.function_iam_role_arn
  command_lambda_role_name = module.cowquote_command.function_iam_role_name
}
