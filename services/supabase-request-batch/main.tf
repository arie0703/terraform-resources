module "supabase_request_batch" {
  source = "../../modules/common/lambda-scheduler"

  service_name        = var.service_name
  schedule_expression = "rate(7 days)"
  runtime             = "nodejs22.x"
  lambda_variables = {
    SECRET_NAME = module.secrets.name
  }
}

module "secrets" {
  source = "../../modules/common/secretsmanager"

  secret_name = var.service_name
}
