locals {
  app_name            = "sandbox-nest"
  newrelic_accound_id = 3575918
}

variable "aws_account_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_public_a_id" {
  type = string
}

variable "subnet_public_c_id" {
  type = string
}

variable "github_repository_url" {
  type    = string
  default = "https://github.com/arie0703/sandbox-nest"
}

variable "notion_database_id" {
  type = string
}
