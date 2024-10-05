variable "discord_public_token" {
    description = "Public token to Discord"
    sensitive = true
}

variable "lambda_layer_path" {
    description = "Path to Lambda layer ZIP"
}

variable "aws_region" {
    description = "Region of AWS"
    default = "us-east-1"
}
