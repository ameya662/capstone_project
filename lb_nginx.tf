# Load Balancer
resource "aws_lb" "nginx_alb" {
  name               = "NginxALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [resource.aws_security_group.nginx_sg.id]
  subnets            = [resource.aws_subnet.public_subnet_1.id, resource.aws_subnet.public_subnet_2.id]
  ip_address_type    = "ipv4"

  enable_deletion_protection = false

}

# Target Group
resource "aws_lb_target_group" "nginxtg" {
  name        = "nginxtg"
  port        = 443
  protocol    = "TCP"
  vpc_id      = resource.aws_vpc.lab_vpc.id
  target_type = "instance"
}

# Load Balancer Listener
resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.nginx_alb.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginxtg.arn
  }
}

# Launch Template
resource "aws_launch_template" "nginxlt" {
  name                   = "nginxlt"
  description            = "Launch template for nginx"
  image_id               = "ami-061dd8b45bc7deb3d" # Replace with actual Amazon Linux 2 AMI ID
  instance_type          = "t3.micro"
  key_name               = "vockey"
  vpc_security_group_ids = [resource.aws_security_group.nginx_sg.id]

  # Reference the external user data file

  user_data = base64encode(templatefile("${path.module}/userdata_nginx.sh.tpl", {
    AWS_ACCESS_KEY_ID     = var.AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY
    AWS_SESSION_TOKEN     = var.AWS_SESSION_TOKEN
    AWS_DEFAULT_REGION    = var.AWS_DEFAULT_REGION
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "nginx-instance"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "nginxasg" {
  desired_capacity     = 1
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = [resource.aws_subnet.public_subnet_1.id, resource.aws_subnet.public_subnet_2.id]
  launch_template {
    id      = aws_launch_template.nginxlt.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.nginxtg.arn]

}

# Auto Scaling Policy
resource "aws_autoscaling_policy" "target_tracking_policy_nginx" {
  name                   = "TargetTrackingPolicyforNginx"
  autoscaling_group_name = aws_autoscaling_group.nginxasg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 90.0
  }
}
