module "ecs" {
  source                  = "../../modules/ecs"
  cluster_name            = "cms"
  app_name                = "cms-backend"
  sg_id                   = module.network.sg_id
  subnet_public_a_id      = module.network.subnet_public_a_id
  task_execution_role_arn = module.iam.task_execution_role_arn
}

module "network" {
  source             = "../../modules/network"
  app_name           = "cms-backend"
  vpc_id             = var.vpc_id
  subnet_public_a_id = var.subnet_public_a_id
}

module "iam" {
  source   = "../../modules/iam"
  app_name = "cms-backend"
}
