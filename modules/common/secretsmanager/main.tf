resource "aws_secretsmanager_secret" "default" {
  name = var.secret_name
}
