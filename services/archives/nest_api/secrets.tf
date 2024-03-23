resource "aws_secretsmanager_secret" "newrelic_license_key" {
  name = "newrelic_license_key"
}

resource "aws_secretsmanager_secret" "notion" {
  name = "notion_secret"
}
