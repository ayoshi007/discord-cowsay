# output "iam_role_arn" {
#   value = aws_iam_role.cowquote_command_role.arn
# }

# output "iam_role_name" {
#   value = aws_iam_role.cowquote_command_role.name
# }

output "dynamodb_table_name" {
  value = aws_dynamodb_table.cowquote_table.name
}
