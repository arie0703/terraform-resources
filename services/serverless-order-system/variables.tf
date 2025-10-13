variable "environment" {
  description = "Environment name"
  type        = string
  default     = "sandbox"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "serverless-order-system"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "nodejs22.x"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 128
}
