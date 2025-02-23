data "aws_vpc" "default" {
  filter {
    name   = "tag:Name"
    values = ["main-network"]
  }
}

data "aws_subnet" "public_a" {
  filter {
    name   = "tag:Name"
    values = ["main-network-public-1a"]
  }
}
