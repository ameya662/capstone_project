provider "aws" {
  region = "us-west-2"
}

# terraform {
#   cloud {
#     workspaces {
#       name = "capstone_project"
#     }
#   }
# }

# provider "newrelic" {
#   account_id = 6264788           # Your New Relic account ID
#   api_key    = var.newrelic_api_key  # Reference the variable (provided via Terraform Cloud Workspace)
#   region     = "US"             # Valid values: "US" or "EU"
# }