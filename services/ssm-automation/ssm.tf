resource "aws_ssm_document" "start_ecs_task" {
  name            = "StartECSTask"
  document_type   = "Automation"
  document_format = "YAML"

  content = templatefile("${path.module}/templates/start_task.yaml.tpl", {
    aws_ecs_cluster = aws_ecs_cluster.main
    aws_ecs_service = aws_ecs_service.automation
  })
}

resource "aws_ssm_document" "stop_ecs_task" {
  name            = "StopECSTask"
  document_type   = "Automation"
  document_format = "YAML"

  content = templatefile("${path.module}/templates/stop_task.yaml.tpl", {
    aws_ecs_cluster = aws_ecs_cluster.main
    aws_ecs_service = aws_ecs_service.automation
  })
}

# IAM Role for SSM Automation
resource "aws_iam_role" "ssm_automation" {
  name = "ssm-automation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ssm_automation" {
  name = "ssm-automation-policy"
  role = aws_iam_role.ssm_automation.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:DescribeTasks",
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Service" = "ssm-automation"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:ListTasks",
          "ecs:ListServices",
          "ecs:DescribeClusters"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.ecs_task_role.arn,
          aws_iam_role.ecs_task_execution_role.arn
        ]
      }
    ]
  })
}
