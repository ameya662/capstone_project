resource "aws_security_group" "db_sg" {
  name        = "DBSG"
  description = "Allow MySQL access for RDS"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    description = "Allow MySQL access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow all
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "DBSG"
    Environment = "Project"
  }
}