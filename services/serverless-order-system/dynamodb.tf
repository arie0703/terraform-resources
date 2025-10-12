# ユーザーテーブル
resource "aws_dynamodb_table" "users" {
  name         = "${var.project_name}-${var.environment}-users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-users"
    Environment = var.environment
    Project     = var.project_name
  }
}

# 商品テーブル
resource "aws_dynamodb_table" "products" {
  name         = "${var.project_name}-${var.environment}-products"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "product_id"

  attribute {
    name = "product_id"
    type = "S"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-products"
    Environment = var.environment
    Project     = var.project_name
  }
}

# 注文テーブル
resource "aws_dynamodb_table" "orders" {
  name         = "${var.project_name}-${var.environment}-orders"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "order_id"

  attribute {
    name = "order_id"
    type = "S"
  }

  # 重複チェック用のGSI
  global_secondary_index {
    name            = "transaction-id-index"
    hash_key        = "transaction_id"
    projection_type = "ALL"
  }

  attribute {
    name = "transaction_id"
    type = "S"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-orders"
    Environment = var.environment
    Project     = var.project_name
  }
}
