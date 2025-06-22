# SNSトピック
resource "aws_sns_topic" "website_monitor" {
  name = "${var.service_name}-topic"

  tags = {
    Name = "${var.service_name}-topic"
  }
}

# SNSトピックポリシー
resource "aws_sns_topic_policy" "website_monitor" {
  arn = aws_sns_topic.website_monitor.arn

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
        Resource = aws_sns_topic.website_monitor.arn
      }
    ]
  })
}

# NOTE: サブスクリプションは手動作成
