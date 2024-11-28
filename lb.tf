# Task 1: Creating an AMI
resource "aws_ami_from_instance" "web_server_ami" {
  name               = "Web Server AMI"
  description        = "Lab AMI for Web Server"
  source_instance_id = aws_instance.testserver.id
}

# Task 2: Creating a Load Balancer
resource "aws_lb" "lab_elb" {
  name               = "LabELB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webserver_sg.id]
  subnets            = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]
}

resource "aws_lb_target_group" "lab_target_group" {
  name        = "lab-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.lab_vpc.id
  target_type = "instance"
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.lab_elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lab_target_group.arn
  }
}

# Task 3: Creating a Launch Template
resource "aws_launch_template" "lab_launch_template" {
  name_prefix        = "lab-app-launch-template"
  description        = "A web server for the load test app"
  instance_type      = "t3.micro"
  image_id           = aws_ami_from_instance.web_server_ami.id
  security_group_ids = [aws_security_group.webserver_sg.id]
}

# Task 4: Creating an Auto Scaling Group
resource "aws_autoscaling_group" "lab_asg" {
  desired_capacity   = 2
  max_size           = 4
  min_size           = 2
  vpc_zone_identifier = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]

  launch_template {
    id      = aws_launch_template.lab_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.lab_target_group.arn]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "Lab Instance"
    propagate_at_launch = true
  }

  scaling_policies {
    policy_type = "TargetTrackingScaling"
    target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
      target_value = 50.0
    }
  }
}

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
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.lab_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.lab_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
}

# Create a security group allowing SSH and HTTP access

resource "aws_security_group" "webserver_sg" {
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
    Name = "Test Server SG"
  }
}
