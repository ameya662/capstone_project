# Supporting Resources (Security Groups, Subnets, VPC)
resource "aws_vpc" "lab_vpc" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Lab VPC"
  }
}
