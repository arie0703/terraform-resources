variable "cluster_name" {
  type = string
}

variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_public_a_id" {
  type = string
}

variable "ingress_cidr" {
  type = string
}

variable "task_execution_role_arn" {
  type = string
}

variable "desired_count" {
  type    = string
  default = 1
}
