provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "arie-terraform-states"
    region = "ap-northeast-1"
    key    = "supabase-request-batch/terraform.tfstate"
  }
}

