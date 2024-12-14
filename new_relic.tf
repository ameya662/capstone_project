module "newrelic-aws-cloud-integrations" {
  source = "newrelic/cloud-integrations/aws"

  newrelic_account_id     = 6264788
  newrelic_account_region = "US"
  name                    = "production"

  include_metric_filters = {
    "AWS/EC2" = [], # include ALL metrics from the EC2 namespace
    "AWS/RDS" = [],
  }
}
