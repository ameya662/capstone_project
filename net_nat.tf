# Elastic IP for NAT Gateway in AZ1
resource "aws_eip" "nat_gateway_eip_az1" {
  domain = "vpc"

  tags = {
    Name = "NAT Gateway EIP AZ1"
    Environment = "Production"  # Adjust as needed
  }
}

# NAT Gateway in AZ1
resource "aws_nat_gateway" "nat_az1" {
  allocation_id = aws_eip.nat_gateway_eip_az1.id
  subnet_id     = aws_subnet.public_subnet_1.id
}

# Route Table for Private Subnet in AZ1
resource "aws_route_table" "private_rt_az1" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_az1.id
  }
}

# Associate Route Table with Private Subnet in AZ1
resource "aws_route_table_association" "private_rt_assoc_az1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt_az1.id
}

# Associate Route Table with Private Subnet in AZ2
resource "aws_route_table_association" "private_rt_assoc_az2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt_az1.id
}
