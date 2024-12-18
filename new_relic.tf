# module "newrelic-aws-cloud-integrations" {
#   source = "github.com/newrelic/terraform-provider-newrelic//examples/modules/cloud-integrations/aws"

#   newrelic_account_id     = 6264788
#   newrelic_account_region = "US"
#   name                    = "production"

#   include_metric_filters = {
#     "AWS/EC2" = [],
#     "AWS/RDS" = [],
#   }
# }
