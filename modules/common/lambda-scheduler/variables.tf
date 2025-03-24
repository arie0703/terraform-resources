variable "service_name" {
  type = string
}

variable "schedule_expression" {
  type = string
}

variable "runtime" {
  type = string
}

variable "lambda_variables" {
  type    = map(string)
  default = {}
}
