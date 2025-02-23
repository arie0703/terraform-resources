data "archive_file" "default" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/function.zip"
}

resource "aws_lambda_function" "default" {
  function_name    = "${var.service_name}-function"
  filename         = data.archive_file.default.output_path
  source_code_hash = data.archive_file.default.output_base64sha256
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  timeout          = 5 # Lambda Edgeは最大5秒
}
