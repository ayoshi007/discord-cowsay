output "invoke_command_sns_arn" {
    value = aws_sns_topic.invoke_command.arn
}

output "lambda_layer_arn" {
    value = aws_lambda_layer_version.cowsay_layer.arn
}

output "invoke_command_sns_name" {
    value = aws_sns_topic.invoke_command.name
}

output "sns_publish_policy_arn" {
    value = aws_iam_policy.proxy_lambda_sns_publish_policy.arn
}
