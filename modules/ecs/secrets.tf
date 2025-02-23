resource "aws_secretsmanager_secret" "ecs" {
  name = "ecs/${var.app_name}"
}
