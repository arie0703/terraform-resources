# Lambda関数のソースコードをZIPファイルに圧縮
data "archive_file" "order_processor_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/order-processor.zip"
}

data "archive_file" "order_api_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/order-api.zip"
}

# 注文処理用Lambda関数
resource "aws_lambda_function" "order_processor" {
  filename         = data.archive_file.order_processor_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-order-processor"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "order-processor.handler"
  source_code_hash = data.archive_file.order_processor_zip.output_base64sha256
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  environment {
    variables = {
      USERS_TABLE     = aws_dynamodb_table.users.name
      PRODUCTS_TABLE  = aws_dynamodb_table.products.name
      ORDERS_TABLE    = aws_dynamodb_table.orders.name
      ORDER_QUEUE_URL = aws_sqs_queue.order_processing.id
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-order-processor"
    Environment = var.environment
    Project     = var.project_name
  }
}

# 注文API用Lambda関数
resource "aws_lambda_function" "order_api" {
  filename         = data.archive_file.order_api_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-order-api"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "order-api.handler"
  source_code_hash = data.archive_file.order_api_zip.output_base64sha256
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  environment {
    variables = {
      USERS_TABLE     = aws_dynamodb_table.users.name
      PRODUCTS_TABLE  = aws_dynamodb_table.products.name
      ORDERS_TABLE    = aws_dynamodb_table.orders.name
      ORDER_QUEUE_URL = aws_sqs_queue.order_processing.id
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-order-api"
    Environment = var.environment
    Project     = var.project_name
  }
}

# SQSからLambdaを呼び出すためのイベントソースマッピング
resource "aws_lambda_event_source_mapping" "order_processor_sqs" {
  event_source_arn                   = aws_sqs_queue.order_processing.arn
  function_name                      = aws_lambda_function.order_processor.arn
  batch_size                         = 10
  maximum_batching_window_in_seconds = 5
}
