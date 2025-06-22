terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "arie-terraform-states"
    region = "ap-northeast-1"
    key    = "watch-website-batch/terraform.tfstate"
  }
}

provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      Service    = "watch-website-batch"
      Repository = "terraform-resources"
    }
  }
}
