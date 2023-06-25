#######################
#       Cluster       #
#######################
resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}


#######################
#       Service       #
#######################
resource "aws_ecs_service" "this" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.this.id
  desired_count   = 2
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.subnet_public_a_id]
    security_groups  = [var.sg_id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}

#######################
#        TASK         #
#######################

resource "aws_ecs_task_definition" "this" {
  family                   = var.app_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = templatefile("${path.module}/container_definitions.json", { ecr_image_url = aws_ecr_repository.this.repository_url, container_name = var.app_name })
  execution_role_arn       = var.task_execution_role_arn

}

#######################
#         ECR         #
#######################
resource "aws_ecr_repository" "this" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"
}
