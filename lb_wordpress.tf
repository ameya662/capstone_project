# Load Balancer
resource "aws_lb" "wordpress_alb" {
  name               = "WordPressALB"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [resource.aws_security_group.wordpress_sg.id]
  subnets            = [resource.aws_subnet.private_subnet_1.id, resource.aws_subnet.private_subnet_2.id]
  ip_address_type    = "ipv4"

  enable_deletion_protection = false
}

# Target Group
resource "aws_lb_target_group" "wordpresstg" {
  name        = "wordpresstg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = resource.aws_vpc.lab_vpc.id
  target_type = "instance"
}

# Load Balancer Listener
resource "aws_lb_listener" "wordpress_listener" {
  load_balancer_arn = aws_lb.wordpress_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpresstg.arn
  }
}

# Launch Template
resource "aws_launch_template" "wordpresslt" {
  name                   = "wordpresslt"
  description            = "Launch template for wordpress"
  image_id               = "ami-061dd8b45bc7deb3d" # Replace with actual Amazon Linux 2 AMI ID
  instance_type          = "t3.micro"
  key_name               = "vockey"
  vpc_security_group_ids = [resource.aws_security_group.wordpress_sg.id]

  # Reference the external user data file
  user_data = base64encode(templatefile("${path.module}/userdata_wordpress.sh.tpl", {
    AWS_ACCESS_KEY_ID     = var.AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY
    AWS_SESSION_TOKEN     = var.AWS_SESSION_TOKEN
    AWS_DEFAULT_REGION    = var.AWS_DEFAULT_REGION
    PER_ACCESS_KEY_ID     = var.PER_ACCESS_KEY_ID
    PER_SECRET_ACCESS_KEY = var.PER_SECRET_ACCESS_KEY  
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "wordpress-instance"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "wordpressasg" {
  desired_capacity     = 1
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = [resource.aws_subnet.private_subnet_1.id, resource.aws_subnet.private_subnet_2.id]
  launch_template {
    id      = aws_launch_template.wordpresslt.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.wordpresstg.arn]

}

# Auto Scaling Policy
resource "aws_autoscaling_policy" "target_tracking_policy_wordpress" {
  name                   = "TargetTrackingPolicyforWP"
  autoscaling_group_name = aws_autoscaling_group.wordpressasg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 90.0
  }
}
