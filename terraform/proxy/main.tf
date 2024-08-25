data "archive_file" "python_discord_cowsay" {
  type        = "zip"
  source_dir = "${var.source_dir}"
  output_path = "${path.module}/source.zip"
}

resource "aws_lambda_function" "discord_cowsay" {
  function_name    = "discord_cowsay_proxy"
  filename         = data.archive_file.python_discord_cowsay.output_path
  source_code_hash = data.archive_file.python_discord_cowsay.output_base64sha256
  role             = var.lambda_exec_role_arn

  runtime = "python3.11"
  handler = var.handler_function
  layers = [var.layer_arn]

  timeout = 3
  environment {
    variables = {
      DISCORD_PUBLIC_TOKEN = var.discord_public_token
      SNS_TOPIC_ARN = var.invoke_command_topic_arn
    }
  }
}

resource "aws_cloudwatch_log_group" "discord_cowsay" {
  name              = "/aws/lambda/${aws_lambda_function.discord_cowsay.function_name}"
  retention_in_days = 30
}

resource "aws_apigatewayv2_api" "lambda" {
  name          = "discord_cowsay_proxy_gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id      = aws_apigatewayv2_api.lambda.id
  name        = "discord_cowsay_proxy_stage"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }
}

resource "aws_apigatewayv2_integration" "discord_cowsay" {
  api_id             = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.discord_cowsay.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "discord_cowsay" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "POST /cowsay"
  target    = "integrations/${aws_apigatewayv2_integration.discord_cowsay.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.discord_cowsay.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*/cowsay"
}
