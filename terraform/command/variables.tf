variable "command_name" {}

variable "source_file" {
    description = "Path to Lambda source file"
}

variable "handler_function" {
    description = "Name of handler function"
}

variable "layer_arn" {}

variable "invoke_command_topic_arn" {
    description = "ARN to publish command invocation messages to"
}

variable "environment_variables" {
    default = null
    type = map
}
