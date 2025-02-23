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
  name                   = var.app_name
  cluster                = aws_ecs_cluster.this.id
  desired_count          = var.desired_count
  enable_execute_command = true
  task_definition        = aws_ecs_task_definition.this.arn
  launch_type            = "FARGATE"

  network_configuration {
    subnets          = [var.subnet_public_a_id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [task_definition]
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
  container_definitions = templatefile("${path.module}/container_definitions.json", {
    ecr_image_url  = aws_ecr_repository.this.repository_url,
    container_name = var.app_name
    log_group_name = aws_cloudwatch_log_group.default.name
  })
  execution_role_arn = var.task_execution_role_arn

  lifecycle {
    #　初回構築後 container_definitions をlifecycleに追加する
    ignore_changes = [container_definitions]
  }
}

#######################
#         ECR         #
#######################
resource "aws_ecr_repository" "this" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"
}


# -------------------------
# Cloudwatch Log Group
# -------------------------
resource "aws_cloudwatch_log_group" "default" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 7
}
