variable "profile" {
    type = string
}

variable "project" {
    type = string
    default = "codedeploy"
}

variable "key_name" {
    type = string
}

variable "subnet" {
    type = string
}

variable "vpc_sg" {
    type = string
}
