# Amazon Linux 2023 の AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# SSM ロール（EC2 インスタンスプロファイル用）
resource "aws_iam_role" "ssm_role" {
  name = "bastion-EC2SSMRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "bastion-ec2-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# セキュリティグループ（SSH なし、MySQL のみ開放 ※用途によって制限推奨）
resource "aws_security_group" "mysql_sg" {
  name        = "mysql-sg"
  description = "Allow MySQL only"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description     = "MySQL from Bastion"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysql-sg"
  }
}

# EC2 インスタンス（SSMログイン対応、MySQL インストール）
resource "aws_instance" "mysql" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.mysql_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_instance_profile.name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo dnf -y install https://dev.mysql.com/get/mysql84-community-release-el9-1.noarch.rpm
              sudo dnf -y install mysql-community-server
              sudo systemctl enable mysqld
              sudo systemctl start mysqld
              EOF

  tags = {
    Name = "mysql-server"
  }
}
