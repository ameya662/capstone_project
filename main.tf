terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.55.0"
    }
    # newrelic = {
    #   source  = "newrelic/newrelic"
    #   version = "~> 3.0"
    # }
  }
}

# Declare the variable for the New Relic API Key
# variable "newrelic_api_key" {
#   type        = string
#   description = "New Relic API Key"
#   sensitive = true
# }

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
  default     = "us-west-2"  # Default region, can be customized
  sensitive   = true
}

variable "PER_ACCESS_KEY_ID" {
  type        = string
  sensitive   = true
}

variable "PER_SECRET_ACCESS_KEY" {
  type        = string
  sensitive   = true
}