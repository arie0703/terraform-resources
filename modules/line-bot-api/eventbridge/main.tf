resource "aws_scheduler_schedule" "default" {
  name                         = var.schedule_name
  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(0 1 * * ? *)"

  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = 1
  }

  target {
    arn      = var.lambda_arn
    role_arn = aws_iam_role.scheduler.arn
  }
}
