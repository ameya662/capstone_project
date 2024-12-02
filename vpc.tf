# Supporting Resources (Security Groups, Subnets, VPC)
resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Lab VPC"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.lab_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.lab_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-west-2b"
}

# Create a security group allowing SSH and HTTP access

resource "aws_security_group" "nginx_sg" {
  name   = "WebServerSG"
  vpc_id = aws_vpc.lab_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Nginx SG"
  }
}

resource "aws_security_group" "wordpress_sg" {
  name   = "WordPressSG"
  vpc_id = aws_vpc.lab_vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WordPress SG"
  }
}