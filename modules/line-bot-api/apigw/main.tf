resource "aws_api_gateway_rest_api" "default" {
  name        = var.service_name
  description = var.service_name

  body = templatefile("${path.module}/openapi.yml", {
    cost_confirmation_invoke_arn = var.cost_confirmation_invoke_arn
    iam_role_arn                 = aws_iam_role.apigw.arn
  })
}

resource "aws_api_gateway_deployment" "default" {
  rest_api_id = aws_api_gateway_rest_api.default.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.default.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "development" {
  deployment_id = aws_api_gateway_deployment.default.id
  rest_api_id   = aws_api_gateway_rest_api.default.id
  stage_name    = "dev"
}
