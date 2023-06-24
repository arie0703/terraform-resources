#######################
#       Cluster       #
#######################
resource "aws_ecs_cluster" "cicd" {
  name = "sandbox-cicd"
}


#######################
#       Service       #
#######################
resource "aws_ecs_service" "cicd" {
  name    = "sandbox-cicd"
  cluster = aws_ecs_cluster.cicd.id
  network_configuration {
    subnets          = [data.aws_subnet.public_a.id, data.aws_subnet.public_c.id]
    security_groups  = [aws_security_group.lb.id]
    assign_public_ip = true
  }
  desired_count = 2

  task_definition = aws_ecs_task_definition.cicd.arn

  launch_type = "FARGATE"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = "sandbox-cicd"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}

#######################
#        TASK         #
#######################

resource "aws_ecs_task_definition" "cicd" {
  family                   = "sandbox-cicd"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = templatefile("${path.module}/container_definitions.json", { ecr_image_url = aws_ecr_repository.cicd.repository_url, container_name = "sandbox-cicd" })
  execution_role_arn       = aws_iam_role.task_execution.arn

}

# resource "aws_ecs_task_set" "this" {
#   service         = aws_ecs_service.cicd.id
#   cluster         = aws_ecs_cluster.cicd.id
#   task_definition = aws_ecs_task_definition.cicd.arn

#   load_balancer {
#     target_group_arn = aws_lb_target_group.blue.arn
#     container_name   = "sandbox-cicd"
#     container_port   = 80
#   }
# }

#######################
#         ECR         #
#######################
resource "aws_ecr_repository" "cicd" {
  name                 = "sandbox-cicd"
  image_tag_mutability = "MUTABLE"
}
