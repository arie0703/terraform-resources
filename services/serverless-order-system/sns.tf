# SNSトピック
resource "aws_sns_topic" "order_notifications" {
  name = "${var.project_name}-notifications"

  tags = {
    Name = "${var.project_name}-notifications"
  }
}

# Slackチャンネルへのサブスクリプション
resource "aws_sns_topic_subscription" "slack_notifications" {
  topic_arn = aws_sns_topic.order_notifications.arn
  protocol  = "https"
  endpoint  = "https://global.sns-api.chatbot.amazonaws.com"
}

# SNSトピックポリシー
resource "aws_sns_topic_policy" "order_notifications" {
  arn = aws_sns_topic.order_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.order_notifications.arn
      }
    ]
  })
}
