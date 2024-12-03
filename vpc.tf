# Supporting Resources (Security Groups, Subnets, VPC)
resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Lab VPC"
  }
}