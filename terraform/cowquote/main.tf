# DynamoDB table
resource "aws_dynamodb_table" "cowquote_table" {
  name           = "CowQuotes"
  billing_mode   = "PROVISIONED"
  read_capacity  = "5"
  write_capacity = "5"
  hash_key       = "Author"
  range_key      = "Id"

  attribute {
    name = "Author"
    type = "S"
  }
  attribute {
    name = "Id"
    type = "S"
  }
}


# role for table updating Lambda
# data "aws_iam_policy_document" "write_to_dynamodb" {
#   statement {
#     actions = [
#       "dynamodb:BatchWriteItem",
#       "dynamodb:DescribeTable",
#       "dynamodb:GetItem",
#       "dynamodb:PutItem",
#       "dynamodb:Query",
#     ]
#     resources = [aws_dynamodb_table.cowquote_table.arn]
#     effect    = "Allow"
#   }
# }

# resource "aws_iam_role" "cowquote_command_role" {
#   name = "cowquote-lambda-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Sid    = ""
#       Principal = {
#         Service = "lambda.amazonaws.com"
#       }
#     }]
#   })
# }

# resource "aws_iam_policy" "write_to_dynamodb" {
#   name        = "cowquote_update_table_policy"
#   description = "Policy for cowquote updating Lambda"
#   policy      = data.aws_iam_policy_document.write_to_dynamodb.json
# }

# resource "aws_iam_role_policy_attachment" "write_to_dynamodb" {
#   role       = aws_iam_role.cowquote_command_role.name
#   policy_arn = aws_iam_policy.write_to_dynamodb.arn
# }


# # table updating Lambda
# data "archive_file" "command_archive" {
#   type        = "zip"
#   source_dir  = var.source_dir
#   output_path = "${path.module}/${var.source_file_name}.zip"
# }

# resource "aws_lambda_function" "cowquote_update_event" {
#   function_name    = "cowquote_table_update"
#   role             = aws_iam_role.cowquote_command_role.arn
#   filename         = data.archive_file.command_archive.output_path
#   source_code_hash = data.archive_file.command_archive.output_base64sha256

#   runtime = "python3.11"
#   handler = var.handler_function
#   layers  = [var.layer_arn]

#   timeout = 15

# }

# resource "aws_iam_role_policy_attachment" "lambda_policy" {
#   role       = aws_iam_role.cowquote_command_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# resource "aws_cloudwatch_log_group" "discord_cowsay" {
#   name              = "/aws/lambda/${aws_lambda_function.cowquote_update_event.function_name}"
#   retention_in_days = 30
# }

# attach role to command Lambda to allow GETs from table
data "aws_iam_policy_document" "batch_get_dynamodb" {
  statement {
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:GetItem",
    ]
    resources = [aws_dynamodb_table.cowquote_table.arn]
    effect    = "Allow"
  }
}
resource "aws_iam_policy" "batch_get_dynamodb" {
  name        = "cowquote_command_table_get_policy"
  description = "Policy for cowquote updating Lambda"
  policy      = data.aws_iam_policy_document.batch_get_dynamodb.json
}

resource "aws_iam_role_policy_attachment" "name" {
  role = var.command_lambda_role_name
  policy_arn = aws_iam_policy.batch_get_dynamodb.arn
}


# # event for triggering Lambda
# resource "aws_cloudwatch_event_rule" "insert_quotes" {
#   name = "insert-quotes"
#   description = "Insert quotes into DynamoDB table with TTL"
#   schedule_expression = "rate(5 minutes)"
# }

# resource "aws_cloudwatch_event_target" "insert_quotes_lambda" {
#   rule = aws_cloudwatch_event_rule.insert_quotes.name
#   arn = aws_lambda_function.cowquote_update_event.arn
# }

# # resource "aws_sns_topic_subscription" "invoke_command_subscription" {
# #   topic_arn = var.invoke_command_topic_arn
# #   protocol = "lambda"
# #   endpoint = aws_lambda_function.command.arn
# #   filter_policy = jsonencode({
# #     "command": [var.command_name]
# #   })
# # }

# resource "aws_lambda_permission" "invoke_command_subscription" {
#   statement_id  = "AllowExecutionFromEventBridge"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.cowquote_update_event.function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.insert_quotes.arn
# }