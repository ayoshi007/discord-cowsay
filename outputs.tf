output "function_name" {
    description = "Name of Proxy Lambda function"
    value = module.proxy.function_name
}

output "base_url" {
    description = "Base URL of API Gateway stage"
    value = module.proxy.base_url
}

output "sns_topic" {
    description = "Name of command invoking SNS topic"
    value = module.common.invoke_command_sns_name
}

output "blep_command_name" {
    description = "Name of commands subscribed to SNS topic"
    value = module.blep_command.function_name
}
