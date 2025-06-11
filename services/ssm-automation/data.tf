data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["main-network"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
