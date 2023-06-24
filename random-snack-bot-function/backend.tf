terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "sandbox-random-snack-bot-tfstate"
    region = "ap-northeast-1"
    key    = "terraform.tfstate"
  }
}
