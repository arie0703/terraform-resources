module "cognito" {
  source       = "../../modules/profile-front/cognito"
  service_name = var.service_name
}
