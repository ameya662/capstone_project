terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.55.0"
    }
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 2.44"
    }
  }
}

# New Relic Provider Configuration
provider "newrelic" {
  account_id = 6264788           # Your New Relic account ID
  api_key    = var.newrelic_api_key  # Reference the variable (provided via Terraform Cloud Workspace)
  region     = "US"             # Valid values: "US" or "EU"
}

# Declare the variable for the New Relic API Key
variable "newrelic_api_key" {
  type        = string
}

# AWS Provider Configuration
variable "AWS_ACCESS_KEY_ID" {
  type        = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
}

variable "AWS_SESSION_TOKEN" {
  type        = string
}

variable "AWS_DEFAULT_REGION" {
  type        = string
  default     = "us-west-2"  # Default region, can be customized
}

variable "PER_ACCESS_KEY_ID" {
  type        = string
}

variable "PER_SECRET_ACCESS_KEY" {
  type        = string
}