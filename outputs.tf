output "function_name" {
    description = "Name of Lambda function"
    value = aws_lambda_function.discord_cowsay.function_name
}

output "base_url" {
    description = "Base URL of API Gateway stage"
    value = aws_apigatewayv2_stage.lambda.invoke_url
}
