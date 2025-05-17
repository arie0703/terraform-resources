#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "amplify_credentials" {
  name        = "${local.service_name}-${var.customer}-credentials"
  description = "${local.service_name}-${var.customer} credentials"
}

data "aws_secretsmanager_secret_version" "amplify_credentials" {
  secret_id = aws_secretsmanager_secret.amplify_credentials.id
}

resource "aws_amplify_app" "this" {
  name       = local.service_name
  platform   = "WEB_COMPUTE"
  repository = "https://github.com/${local.github_organization_name}/${local.github_repository_name}"
  build_spec = file("${path.module}/amplify.yml")

  enable_auto_branch_creation = false
  enable_branch_auto_deletion = false

  enable_basic_auth        = false
  enable_branch_auto_build = true

  environment_variables = {
    NEXT_PUBLIC_COMPANY_ID   = var.company_id
    NEXT_PUBLIC_SAMPLE_VALUE = jsondecode(data.aws_secretsmanager_secret_version.amplify_credentials.secret_string)["SAMPLE_VALUE"]
  }

  access_token = var.access_token

  lifecycle {
    ignore_changes = [access_token]
  }
}

resource "aws_cloudwatch_log_group" "amplify" {
  name              = "/aws/amplify/${aws_amplify_app.this.id}"
  retention_in_days = 14
}
