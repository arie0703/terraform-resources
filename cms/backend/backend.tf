terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "sandbox-app-terraform"
    region = "ap-northeast-1"
    key    = "terraform.tfstate"
  }
}
