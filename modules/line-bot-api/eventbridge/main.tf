resource "aws_scheduler_schedule" "default" {
  name                         = var.schedule_name
  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(0 10 25 * ? *)"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = var.lambda_arn
    role_arn = aws_iam_role.scheduler.arn
  }
}
