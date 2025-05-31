resource "aws_ecr_repository" "bastion" {
  name = "bastion-container"
}

resource "aws_ecs_cluster" "bastion" {
  name = "bastion-cluster"
}

# セキュリティグループ
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = data.aws_vpc.selected.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "bastion" {
  name              = "/ecs/bastion"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "bastion_task" {
  family                   = "bastion-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = templatefile("${path.module}/container_definition.json", {
    ecr_image_url = aws_ecr_repository.bastion.repository_url
    log_group     = aws_cloudwatch_log_group.bastion.name
  })

  runtime_platform {
    operating_system_family = "LINUX"
  }
}

# ECSサービス
resource "aws_ecs_service" "bastion_service" {
  name            = "bastion-service"
  cluster         = aws_ecs_cluster.bastion.id
  task_definition = aws_ecs_task_definition.bastion_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [data.aws_subnet.public_a.id]
    security_groups  = [aws_security_group.bastion_sg.id]
    assign_public_ip = true
  }

  enable_execute_command = true
}
