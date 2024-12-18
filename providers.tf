provider "aws" {
  region = "us-west-2"
  allowed_account_ids = ["764121959454"]
}

terraform {
  cloud {
    workspaces {
      name = "capstone_project"
    }
  }
}
