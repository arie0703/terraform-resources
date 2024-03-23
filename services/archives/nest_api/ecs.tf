#######################
#       Cluster       #
#######################
resource "aws_ecs_cluster" "this" {
  name = local.app_name
}


#######################
#       Service       #
#######################
resource "aws_ecs_service" "this" {
  name            = local.app_name
  cluster         = aws_ecs_cluster.this.id
  desired_count   = 2
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [data.aws_subnet.public_a.id, data.aws_subnet.public_c.id]
    security_groups  = [aws_security_group.lb.id]
    assign_public_ip = true
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = local.app_name
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition, load_balancer]
  }
}

#######################
#        TASK         #
#######################

resource "aws_ecs_task_definition" "this" {
  family                   = local.app_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = templatefile("${path.module}/container_definitions.json", { ecr_image_url = aws_ecr_repository.this.repository_url, container_name = local.app_name })
  execution_role_arn       = aws_iam_role.task_execution.arn

}

# resource "aws_ecs_task_set" "this" {
#   service         = aws_ecs_service.this.id
#   cluster         = aws_ecs_cluster.this.id
#   task_definition = aws_ecs_task_definition.this.arn

#   load_balancer {
#     target_group_arn = aws_lb_target_group.blue.arn
#     container_name   = local.app_name
#     container_port   = 80
#   }
# }

#######################
#         ECR         #
#######################
resource "aws_ecr_repository" "this" {
  name                 = local.app_name
  image_tag_mutability = "MUTABLE"
}
