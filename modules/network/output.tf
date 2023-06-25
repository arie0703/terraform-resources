output "sg_id" {
  value = aws_security_group.this.id
}

output "subnet_public_a_id" {
  value = data.aws_subnet.public_a.id
}
