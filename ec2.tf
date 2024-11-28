# Create a public subnet
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
}

# Create a security group allowing SSH and HTTP access
resource "aws_security_group" "testserver_sg" {
  name   = "TestServerSG"
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
    Name = "Test Server SG"
  }
}

# Create the EC2 instance
resource "aws_instance" "testserver" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet_1.id
  security_group_ids     = [aws_security_group.testserver_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "testserver"
  }
}

# Data source for Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Modify the AMI creation block to reference the instance ID dynamically
resource "aws_ami_from_instance" "web_server_ami" {
  name               = "Web Server AMI"
  description        = "Lab AMI for Web Server"
  source_instance_id = aws_instance.testserver.id
}
