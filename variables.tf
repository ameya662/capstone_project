# AWS Provider Configuration
variable "AWS_ACCESS_KEY_ID" {
  type        = string
  sensitive   = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  sensitive   = true
}

variable "AWS_SESSION_TOKEN" {
  type        = string
  sensitive   = true
}

variable "AWS_DEFAULT_REGION" {
  type        = string
  default     = "us-west-2"
}

variable "PER_ACCESS_KEY_ID" {
  type        = string
  sensitive   = true
}

variable "PER_SECRET_ACCESS_KEY" {
  type        = string
  sensitive   = true
}