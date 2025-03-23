resource "null_resource" "go_build" {
  # 実行時にtriggersのコメントアウトを外す

  # triggers = {
  #   always_run = timestamp()
  # }
  provisioner "local-exec" {
    command = "cd ${path.module}/src/${var.function_name}/cmd/ && GOOS=linux GOARCH=amd64 go build -o ../build/bootstrap ../main.go"
  }
}

data "archive_file" "default" {
  type        = "zip"
  source_file = "${path.module}/src/${var.function_name}/build/bootstrap"
  output_path = "${path.module}/src/${var.function_name}/archive/function.zip"

  depends_on = [null_resource.go_build]
}

resource "aws_lambda_function" "default" {
  function_name    = var.function_name
  filename         = data.archive_file.default.output_path
  source_code_hash = data.archive_file.default.output_base64sha256
  runtime          = "provided.al2"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  timeout          = 60

  environment {
    variables = {
      LINE_USER_ID       = ""
      LINE_CHANNEL_TOKEN = ""
    }
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
  source_arn    = var.scheduler_arn
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 1
}
