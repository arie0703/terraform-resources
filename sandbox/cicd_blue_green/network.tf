resource "aws_security_group" "lb" {
  name        = "sg_lb_cicd"
  description = "sg_lb_cicd"
  vpc_id      = data.aws_vpc.main.id

  tags = { Name = "sg_lb_cicd" }
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["alb-ecs-vpc"]
  }
}

data "aws_subnet" "public_a" {
  filter {
    name   = "tag:Name"
    values = ["alb-ecs-vpc-public-ap-northeast-1a"]
  }
}


data "aws_subnet" "public_c" {
  filter {
    name   = "tag:Name"
    values = ["alb-ecs-vpc-public-ap-northeast-1c"]
  }
}
