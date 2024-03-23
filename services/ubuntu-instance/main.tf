module "ec2" {
  source        = "../../modules/ec2"
  instance_name = "sandbox-ubuntu"
  instance_type = "t2.micro"
  ami_id        = data.aws_ami.ubuntu.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20240228"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}