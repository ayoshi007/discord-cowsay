output "function_name" {
    description = "Name of Lambda function"
    value = aws_lambda_function.command.function_name
}

output "function_arn" {
    value = aws_lambda_function.command.arn
}

output "function_iam_role_arn" {
    value = aws_iam_role.command_lambda_exec.arn
}

output "function_iam_role_name" {
    value = aws_iam_role.command_lambda_exec.name
}
