module "ecs" {
  source = "../../modules/ecs"

  cluster_name            = var.cluster_name
  app_name                = var.service_name
  vpc_id                  = data.aws_vpc.default.id
  subnet_public_a_id      = data.aws_subnet.public_a.id
  ingress_cidr            = var.cidr
  task_execution_role_arn = module.iam.task_execution_role_arn
  desired_count           = 0 # 利用しないときは0
}

module "iam" {
  source = "../../modules/iam"

  app_name    = var.service_name
  github_repo = "repo:arie0703/mock-app-profile-service-api:*"
}
