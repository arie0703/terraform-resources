
data "archive_file" "default" {
  type        = "zip"
  source_dir  = "${path.module}/src/${var.service_name}"
  output_path = "${path.module}/src/outputs/${var.service_name}.zip"
}

resource "aws_lambda_function" "default" {
  function_name    = var.service_name
  filename         = data.archive_file.default.output_path
  source_code_hash = data.archive_file.default.output_base64sha256
  runtime          = var.runtime
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  timeout          = 60

  environment {
    variables = var.lambda_variables
  }

  lifecycle {
    ignore_changes = [
      environment,
    ]
  }
}

resource "aws_lambda_permission" "default" {
  statement_id  = "default-scheduler"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn    = aws_scheduler_schedule.default.arn
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.service_name}"
  retention_in_days = 1
}
