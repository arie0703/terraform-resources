output "arn" {
  value = aws_secretsmanager_secret.default.arn
}

output "name" {
  value = aws_secretsmanager_secret.default.name
}
