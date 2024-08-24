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

data "archive_file" "python_discord_cowsay" {
  type        = "zip"
  source_file = "${path.module}/proxy.py"
  output_path = "${path.module}/archives/proxy.zip"
}

data "archive_file" "cowsay_layer" {
  type        = "zip"
  source_dir = "${path.module}/${var.LAYER_ZIP_PATH}"
  output_path = "${path.module}/archives/layer.zip"
}

resource "aws_lambda_layer_version" "cowsay_layer" {
  layer_name = "cowsay_layer"
  filename = data.archive_file.cowsay_layer.output_path
  source_code_hash = data.archive_file.cowsay_layer.output_base64sha256
  compatible_runtimes = ["python3.11"]
}

resource "aws_lambda_function" "discord_cowsay" {
  function_name    = "discord_cowsay_proxy"
  filename         = data.archive_file.python_discord_cowsay.output_path
  source_code_hash = data.archive_file.python_discord_cowsay.output_base64sha256
  role             = aws_iam_role.lambda_exec.arn

  runtime = "python3.11"
  handler = "proxy.lambda_handler"
  layers = [aws_lambda_layer_version.cowsay_layer.arn]

  timeout = 3
  environment {
    variables = {
      DISCORD_PUBLIC_TOKEN = var.DISCORD_PUBLIC_TOKEN
    }
  }
}

resource "aws_cloudwatch_log_group" "discord_cowsay" {
  name              = "/aws/lambda/${aws_lambda_function.discord_cowsay.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
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
