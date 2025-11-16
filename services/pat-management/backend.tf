terraform {
  backend "s3" {
    bucket = "arie-terraform-states"
    region = "ap-northeast-1"
    key    = "pat-management/terraform.tfstate"
  }
}
