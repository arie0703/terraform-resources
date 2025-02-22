data "archive_file" "default" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/src/index.zip"
}

resource "aws_lambda_function" "default" {
  function_name                  = "${var.service_name}-function"
  filename                       = data.archive_file.default.output_path
  source_code_hash               = data.archive_file.default.output_base64sha256
  runtime                        = "nodejs22.x"
  role                           = aws_iam_role.lambda.arn
  handler                        = "index.handler"
  reserved_concurrent_executions = 0
  timeout                        = 60

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.default.url
    }
  }
}

resource "aws_lambda_permission" "default" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.default.arn
}

resource "aws_lambda_event_source_mapping" "default" {
  event_source_arn = aws_sqs_queue.default.arn
  function_name    = aws_lambda_function.default.arn
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.service_name}-function"
  retention_in_days = 1
}
