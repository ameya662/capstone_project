resource "aws_security_group" "wordpress_sg" {
  name   = "WordPressSG"
  vpc_id = aws_vpc.lab_vpc.id

  ingress {
    description = "Allow SSH from my public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"] 
  }

  ingress {
    description      = "Allow HTTP from Nginx SG"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.nginx_sg.id] # Reference Nginx SG
  }

  #Allow ICMP from nginx_sg
  ingress {
    description      = "Allow ICMP from Nginx SG"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    security_groups  = [aws_security_group.nginx_sg.id] # Reference Nginx SG
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