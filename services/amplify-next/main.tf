module "amplify-next-sample" {
  source       = "../../modules/amplify-next"
  customer     = "sample"
  company_id   = 123
  access_token = var.access_token
}
