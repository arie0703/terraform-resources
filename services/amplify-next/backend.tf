terraform {
  required_version = "1.10.5"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "arie-terraform-states"
    region = "ap-northeast-1"
    key    = "amplify-next/terraform.tfstate"
  }
}
