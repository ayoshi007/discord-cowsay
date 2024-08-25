variable "discord_public_token" {
    description = "Public token to Discord"
    sensitive = true
}


variable "source_dir" {
    description = "Path to Lambda source files"
}

variable "handler_function" {
    description = "Name of handler function"
}

variable "invoke_command_topic_arn" {
    description = "ARN to publish command invocation messages to"
}

variable "layer_arn" {}

variable "lambda_exec_role_arn" {}