data "archive_file" "cowsay_layer" {
  type        = "zip"
  source_dir = "${var.layer_source_dir}"
  output_path = "${path.module}/layer.zip"
}

resource "aws_lambda_layer_version" "cowsay_layer" {
  layer_name = "cowsay_layer"
  filename = data.archive_file.cowsay_layer.output_path
  source_code_hash = data.archive_file.cowsay_layer.output_base64sha256
  compatible_runtimes = ["python3.11"]
}

resource "aws_sns_topic" "invoke_command" {
    name = "invoke-command-topic"
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

# resource "aws_iam_role" "sns_publish" {
#   name = "sns_publish"
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

# resource "aws_iam_role_policy_attachment" "sns_publish_policy" {
#   role       = aws_iam_role.sns_publish.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

