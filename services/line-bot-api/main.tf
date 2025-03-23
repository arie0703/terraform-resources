module "lambda_cost_confirmation" {
  source = "../../modules/line-bot-api/lambda"

  function_name = "cost-confirmation"
  scheduler_arn = module.eventbridge_cost_confirmation.scheduler_arn
}

module "apigw" {
  source = "../../modules/line-bot-api/apigw"

  service_name                 = var.service_name
  cost_confirmation_invoke_arn = module.lambda_cost_confirmation.invoke_arn
}

module "eventbridge_cost_confirmation" {
  source = "../../modules/line-bot-api/eventbridge"

  schedule_name = "line-cost-confirmation-schedule"
  lambda_arn    = module.lambda_cost_confirmation.function_arn
}
