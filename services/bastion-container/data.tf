# 既存VPCデータ参照
data "aws_vpc" "selected" {
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
