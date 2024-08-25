variable "command_name" {}

variable "discord_public_token" {
    description = "Public token to Discord"
    sensitive = true
}

variable "source_file" {
    description = "Path to Lambda source file"
}

variable "handler_function" {
    description = "Name of handler function"
}

variable "layer_arn" {}
variable "lambda_exec_role_arn" {}


variable "invoke_command_topic_arn" {
    description = "ARN to publish command invocation messages to"
}

