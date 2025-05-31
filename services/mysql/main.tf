resource "aws_secretsmanager_secret" "mysql" {
  name = "mysql_secrets"
}

data "aws_secretsmanager_secret_version" "mysql" {
  secret_id = aws_secretsmanager_secret.mysql.id
}

resource "mysql_database" "app" {
  name = "sample_db"
}
