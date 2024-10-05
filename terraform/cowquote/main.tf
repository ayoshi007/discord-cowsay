# DynamoDB table
resource "aws_dynamodb_table" "cowquote_table" {
  name           = "CowQuotes"
  billing_mode   = "PROVISIONED"
  read_capacity  = "5"
  write_capacity = "5"
  hash_key       = "Id"

  attribute {
    name = "Id"
    type = "S"
  }
}


# attach role to command Lambda to allow GETs from table
data "aws_iam_policy_document" "scan_dynamodb" {
  statement {
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
    ]
    resources = [aws_dynamodb_table.cowquote_table.arn]
    effect    = "Allow"
  }
}
resource "aws_iam_policy" "scan_dynamodb" {
  name        = "cowquote_command_table_get_policy"
  description = "Policy for scanning CowQuoutes table"
  policy      = data.aws_iam_policy_document.scan_dynamodb.json
}

resource "aws_iam_role_policy_attachment" "scan_dynamodb" {
  role = var.command_lambda_role_name
  policy_arn = aws_iam_policy.scan_dynamodb.arn
}

