data "http" "my_ip" {
  url = "http://checkip.amazonaws.com"
}

# Create a security group allowing SSH and HTTP access
resource "aws_security_group" "nginx_sg" {
  name   = "NginxSG"
  vpc_id = aws_vpc.lab_vpc.id

  ingress {
    description = "Allow SSH from my public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"] # Fetch and use public IP
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    description      = "Allow Squid from Wordpress SG"
    from_port        = 3128
    to_port          = 3128
    protocol         = "tcp"
    security_groups  = [aws_security_group.wordpress_sg.id] # Reference Nginx SG
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