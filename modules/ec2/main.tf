resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    "Name" = var.instance_name
  }

  iam_instance_profile = aws_iam_instance_profile.ssm.id
}

resource "aws_iam_instance_profile" "ssm" {
  name = "SSM_test"
  role = data.aws_iam_role.ssm.name
}

data "aws_iam_role" "ssm" {
  name = "SSM_test"
}