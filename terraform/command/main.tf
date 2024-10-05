data "archive_file" "command_archive" {
  type        = "zip"
  source_file = "${var.source_file}"
  output_path = "${path.module}/${var.command_name}.zip"
}

resource "aws_iam_role" "command_lambda_exec" {
  name = "${var.command_name}-lambda-exec-role"
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


resource "aws_lambda_function" "command" {
  function_name    = var.command_name
  filename         = data.archive_file.command_archive.output_path
  source_code_hash = data.archive_file.command_archive.output_base64sha256
  role             = aws_iam_role.command_lambda_exec.arn

  runtime = "python3.11"
  handler = var.handler_function
  layers = [var.layer_arn]

  timeout = 15

  environment {
    variables = var.environment_variables
  }
}

resource "aws_cloudwatch_log_group" "command" {
  name              = "/aws/lambda/${aws_lambda_function.command.function_name}"
  retention_in_days = 30
}


resource "aws_sns_topic_subscription" "invoke_command_subscription" {
  topic_arn = var.invoke_command_topic_arn
  protocol = "lambda"
  endpoint = aws_lambda_function.command.arn
  filter_policy = jsonencode({
    "command": [var.command_name]
  })
}

resource "aws_lambda_permission" "invoke_command_subscription" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.command.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.invoke_command_topic_arn
}


resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.command_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
