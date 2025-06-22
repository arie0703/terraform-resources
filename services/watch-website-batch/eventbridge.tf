# EventBridgeスケジューラー
resource "aws_scheduler_schedule" "website_monitor" {
  name       = "${var.service_name}-schedule"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(10 minutes)"

  target {
    arn      = aws_lambda_function.watch_website.arn
    role_arn = aws_iam_role.scheduler_role.arn
  }
}

# EventBridgeスケジューラー用のIAMロール
resource "aws_iam_role" "scheduler_role" {
  name = "${var.service_name}-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })
}

# EventBridgeスケジューラー用のIAMポリシー
resource "aws_iam_role_policy" "scheduler_policy" {
  name = "${var.service_name}-scheduler-policy"
  role = aws_iam_role.scheduler_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = aws_lambda_function.watch_website.arn
      }
    ]
  })
}
