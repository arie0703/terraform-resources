resource "aws_iam_role" "apigw" {
  name = "${var.service_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "apigw" {
  role       = aws_iam_role.apigw.name
  policy_arn = aws_iam_policy.lambda_exec.arn
}

resource "aws_iam_policy" "lambda_exec" {
  name        = "${var.service_name}-lambda_exec-policy"
  path        = "/"
  description = "IAM policy for ${var.service_name}"
  policy      = data.aws_iam_policy_document.lambda_exec.json
}

data "aws_iam_policy_document" "lambda_exec" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = ["*"]
  }
}
