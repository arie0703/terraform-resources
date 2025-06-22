variable "service_name" {
  description = "Name of the service"
  type        = string
  default     = "watch-website-batch"
}

variable "website_url" {
  description = "URL of the website to monitor"
  type        = string
  default     = "https://example.com"
}

variable "target_string" {
  description = "String to search for on the website"
  type        = string
  default     = "example"
}
