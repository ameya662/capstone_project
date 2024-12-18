module "newrelic-aws-cloud-integrations" {
  source = "github.com/newrelic/terraform-provider-newrelic//examples/modules/cloud-integrations/aws"

  newrelic_account_id     = 6264788
  newrelic_account_region = "US"
  name                    = "production"

  include_metric_filters = {
    "AWS/EC2" = [],
    "AWS/RDS" = [],
  }
}

resource "newrelic_integration_aws" "example" {
  account_id         = 764121959454
  linked_account_name = "MyAWSAccountIntegration"
  role_arn           = "arn:aws:iam::764121959454:role/NewRelicIntegrationRole"
}