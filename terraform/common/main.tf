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

data "aws_iam_policy_document" "proxy_publish_sns_policy_doc" {
  statement {
    actions = ["sns:Publish"]
    resources = [aws_sns_topic.invoke_command.arn]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "proxy_lambda_sns_publish_policy" {
  name = "proxy-lambda-policy"
  description = "Policy for Discord cowsay proxy lambda"
  policy = data.aws_iam_policy_document.proxy_publish_sns_policy_doc.json
}

resource "aws_iam_role" "command_lambda_exec" {
  name = "command-lambda-exec-role"
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
  role       = aws_iam_role.command_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
