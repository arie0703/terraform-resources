module "cicd" {
    source = "./cicd"
    ecr_repository_name = module.ecr.ecr_repository_name
    ecs_cluster_name = module.ecs.ecs_cluster_name
    ecs_service_name = module.ecs.ecs_service_name
    artifact_input = module.s3.artifact_input
    artifact_output = module.s3.artifact_output
}

module "s3" {
    source = "./s3"
}


module "ecs" {
    source = "./ecs"
}

module "ecr" {
    source = "./ecr"
}
