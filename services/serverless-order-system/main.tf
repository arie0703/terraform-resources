# このファイルは他のTerraformファイルを統合するためのメインファイルです
# 各リソースは個別のファイルで定義されています：
# - terraform.tf: ProviderとBackend設定
# - variables.tf: 変数定義
# - dynamodb.tf: DynamoDBテーブル定義
# - sqs.tf: SQSキュー定義
# - iam.tf: IAMロール・ポリシー定義
# - lambda.tf: Lambda関数定義

# ローカル変数
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# 出力値
output "users_table_name" {
  description = "Name of the users DynamoDB table"
  value       = aws_dynamodb_table.users.name
}

output "products_table_name" {
  description = "Name of the products DynamoDB table"
  value       = aws_dynamodb_table.products.name
}

output "orders_table_name" {
  description = "Name of the orders DynamoDB table"
  value       = aws_dynamodb_table.orders.name
}

output "order_queue_url" {
  description = "URL of the order processing SQS queue"
  value       = aws_sqs_queue.order_processing.id
}

output "order_processor_function_name" {
  description = "Name of the order processor Lambda function"
  value       = aws_lambda_function.order_processor.function_name
}

output "order_api_function_name" {
  description = "Name of the order API Lambda function"
  value       = aws_lambda_function.order_api.function_name
}
