terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.55.0"
    }
  }
}

# Configure terraform
terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 2.44"
    }
  }
}

# Configure the New Relic provider
provider "newrelic" {
  account_id = 6264788
  api_key = NRAK-LWRZZ1TUQLMPF4NQIYEGJR0EN8M    # usually prefixed with 'NRAK'
  region = "US"                    # Valid regions are US and EU
}