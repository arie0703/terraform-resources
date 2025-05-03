module "lambda_cost_confirmation" {
  source = "../../modules/line-bot-api/lambda"

  function_name = "cost-confirmation"
  scheduler_arn = module.eventbridge_cost_confirmation.scheduler_arn
}

module "eventbridge_cost_confirmation" {
  source = "../../modules/line-bot-api/eventbridge"

  schedule_name = "line-cost-confirmation-schedule"
  lambda_arn    = module.lambda_cost_confirmation.function_arn
}

module "lambda_search_property-batch" {
  source = "../../modules/common/lambda-scheduler"

  service_name        = "search-property-batch"
  schedule_expression = "rate(7 days)"
  runtime             = "nodejs22.x"
}
