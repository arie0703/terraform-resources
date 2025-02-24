resource "aws_cognito_user_pool" "default" {
  name = "${var.service_name}-pool"

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  alias_attributes         = ["email", "preferred_username"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length                   = 8
    require_uppercase                = true
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  schema {
    name                = "preferred_username"
    attribute_data_type = "String"
    mutable             = true
    required            = false
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    mutable             = true
    required            = true
    string_attribute_constraints {
      min_length = 1
      max_length = 100
    }
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
    email_subject        = "メールアドレスの確認"
    email_message        = "あなたのメールアドレスを確認するには、以下のリンクをクリックしてください: {####}"
  }
}


resource "aws_cognito_user_pool_domain" "default" {
  domain       = "${var.service_name}-pool"
  user_pool_id = aws_cognito_user_pool.default.id
}

resource "aws_cognito_user_pool_client" "default" {
  name         = "${var.service_name}-client"
  user_pool_id = aws_cognito_user_pool.default.id

  callback_urls                = [var.cloudfront_distribution_url]
  supported_identity_providers = ["COGNITO"]

  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid"]
}
