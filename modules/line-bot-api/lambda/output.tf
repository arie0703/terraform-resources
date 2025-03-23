output "invoke_arn" {
  value = aws_lambda_function.default.invoke_arn
}

output "function_arn" {
  value = aws_lambda_function.default.arn
}
