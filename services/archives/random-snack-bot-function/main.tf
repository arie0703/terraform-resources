resource "aws_dynamodb_table" "this" {
  hash_key       = "name"
  billing_mode   = "PROVISIONED"
  name           = "snacks"
  read_capacity  = 1
  stream_enabled = false
  write_capacity = 1

  attribute {
    name = "name"
    type = "S"
  }

  point_in_time_recovery {
    enabled = false
  }

  timeouts {}

}

resource "aws_cloudwatch_event_rule" "this" {
  description         = "everyday 15:00"
  event_bus_name      = "default"
  name                = "everyday15"
  schedule_expression = "cron(0 6 ? * MON-FRI *)"
}

resource "aws_lambda_function" "slack-bot-random-snack" {
  architectures = [
    "x86_64",
  ]
  function_name = "${local.app_name}-function"
  memory_size   = 128
  package_type  = "Image"
  role          = aws_iam_role.lambda.arn
  image_uri     = "${aws_ecr_repository.this.repository_url}:latest"

  environment {
    variables = {
      WEBHOOK_URL = var.slack_webhook_url
    }
  }

  ephemeral_storage {
    size = 512
  }

  tracing_config {
    mode = "PassThrough"
  }

  lifecycle {
    ignore_changes = [
      image_uri,
      last_modified
    ]
  }
}

resource "aws_ecr_repository" "this" {
  name                 = local.app_name
  image_tag_mutability = "MUTABLE"
}
