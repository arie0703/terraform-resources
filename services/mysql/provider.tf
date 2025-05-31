terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    mysql = {
      source  = "petoju/mysql"
      version = "3.0.23"
    }
  }
  backend "s3" {
    bucket = "arie-terraform-states"
    region = "ap-northeast-1"
    key    = "mysql/terraform.tfstate"
  }
}

provider "mysql" {
  endpoint = jsondecode(data.aws_secretsmanager_secret_version.mysql.secret_string)["MYSQL_HOST"]
  username = jsondecode(data.aws_secretsmanager_secret_version.mysql.secret_string)["MYSQL_USER"]
  password = jsondecode(data.aws_secretsmanager_secret_version.mysql.secret_string)["MYSQL_PASSWORD"]
}
