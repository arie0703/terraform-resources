module "lambda_edge" {
  source       = "../../modules/static-website/lambda-edge"
  service_name = var.service_name
  providers = {
    aws = aws.global
  }
}

module "cognito" {
  source                      = "../../modules/static-website/cognito"
  service_name                = var.service_name
  cloudfront_distribution_url = var.cloudfront_distribution_url # TODO: CloudFrontのモジュールも作成してoutputから参照する
}
