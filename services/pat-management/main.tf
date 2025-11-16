data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret" "common" {
  arn = "arn:aws:secretsmanager:ap-northeast-1:${data.aws_caller_identity.current.account_id}:secret:common-secrets"
}

data "aws_secretsmanager_secret_version" "common" {
  secret_id = data.aws_secretsmanager_secret.common.id
}
