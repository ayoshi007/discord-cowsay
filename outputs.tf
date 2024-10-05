output "function_name" {
    description = "Name of Proxy Lambda function"
    value = module.proxy.function_name
}

output "base_url" {
    description = "Base URL of API Gateway stage"
    value = module.proxy.base_url
}

output "dynamodb_table" {
    description = "Name of DynamoDB table of quotes"
    value = module.cowquote_infra.dynamodb_table_name
}
