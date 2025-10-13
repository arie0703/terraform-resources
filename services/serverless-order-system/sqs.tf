# 注文処理用SQSキュー
resource "aws_sqs_queue" "order_processing" {
  name                       = "${var.project_name}-${var.environment}-order-processing"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 1209600 # 14 days
  receive_wait_time_seconds  = 0
  visibility_timeout_seconds = 60

  tags = {
    Name        = "${var.project_name}-${var.environment}-order-processing"
    Environment = var.environment
    Project     = var.project_name
  }
}

# デッドレターキュー
resource "aws_sqs_queue" "order_processing_dlq" {
  name                      = "${var.project_name}-${var.environment}-order-processing-dlq"
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Name        = "${var.project_name}-${var.environment}-order-processing-dlq"
    Environment = var.environment
    Project     = var.project_name
  }
}

# メインキューとDLQの関連付け
resource "aws_sqs_queue_redrive_policy" "order_processing" {
  queue_url = aws_sqs_queue.order_processing.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.order_processing_dlq.arn
    maxReceiveCount     = 3
  })
}
