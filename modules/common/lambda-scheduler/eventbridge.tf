resource "aws_scheduler_schedule" "default" {
  name                         = "${var.service_name}-schedule"
  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = var.schedule_expression

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.default.arn
    role_arn = aws_iam_role.scheduler.arn
  }
}
