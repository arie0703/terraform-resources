variable "supabase_token" {
  type    = string
  default = null
}

variable "organization_id" {
  type        = string
  description = "organization ID"
}

variable "project_name" {
  type        = string
  description = "Project Name"
}

variable "region" {
  type        = string
  description = "region"
  default     = "ap-northeast-1"
}

variable "database_password" {
  type        = string
  description = "DB Password"
  default     = "XXXXXXXX"
}
