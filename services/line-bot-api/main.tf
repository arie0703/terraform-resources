module "lambda_cost_confirmation" {
  source = "../../modules/line-bot-api/lambda"

  function_name = "cost-confirmation"
}

module "apigw" {
  source = "../../modules/line-bot-api/apigw"

  service_name                 = var.service_name
  cost_confirmation_invoke_arn = module.lambda_cost_confirmation.invoke_arn
}
