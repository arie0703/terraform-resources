# ECRリポジトリ
resource "aws_ecr_repository" "watch_website" {
  name                 = "watch-website-batch"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "watch-website-batch"
  }
}

# Lambda関数
resource "aws_lambda_function" "watch_website" {
  function_name = "watch-website-batch"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.watch_website.repository_url}:latest"
  timeout       = 60
  memory_size   = 256

  environment {
    variables = {
      WEBSITE_URL   = var.website_url
      TARGET_STRING = var.target_string
      SNS_TOPIC_ARN = aws_sns_topic.website_monitor.arn
    }
  }

  lifecycle {
    ignore_changes = [
      environment[0].variables
    ]
  }

  tags = {
    Name = "watch-website-batch"
  }
}
