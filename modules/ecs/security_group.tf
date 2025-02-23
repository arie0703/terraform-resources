resource "aws_security_group" "ecs" {
  name        = "${var.app_name}-ecs-sg"
  description = "ECS Security Group"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "ecs_allow_80" {
  security_group_id = aws_security_group.ecs.id
  cidr_ipv4         = var.ingress_cidr
  from_port         = 3000
  to_port           = 3000
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ecs_egress" {
  security_group_id = aws_security_group.ecs.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
