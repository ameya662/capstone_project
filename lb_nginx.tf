# Load Balancer
resource "aws_lb" "nginx_alb" {
  name               = "NginxALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [resource.aws_security_group.nginx_sg.id]
  subnets            = [resource.aws_subnet.public_subnet_1.id, resource.aws_subnet.public_subnet_2.id]
  ip_address_type    = "ipv4"
}

# Target Group
resource "aws_lb_target_group" "nginxtg" {
  name        = "nginxtg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = resource.aws_vpc.lab_vpc.id
  target_type = "instance"
}

# Load Balancer Listener
resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.nginx_alb.arn
  port              = 80
  protocol          = "HTTP"

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
  user_data = <<EOF

#!/bin/bash
sudo yum update -y
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Variables
CONFIG_PATH="/etc/nginx/conf.d/wp.conf"
#DOMAIN_NAME="your-domain.com"
LB_NAME="WordPressALB" # Replace with your load balancer's name
AWS_REGION="us-west-2" # Replace with your AWS region

# Fetch the private DNS name of the load balancer using AWS CLI
LB_DNS_NAME=$(aws elbv2 describe-load-balancers \
  --names $LB_NAME \
  --region $AWS_REGION \
  --query "LoadBalancers[0].DNSName" \
  --output text)

if [[ -z "$LB_DNS_NAME" ]]; then
  echo "Error: Failed to fetch Load Balancer DNS Name."
  exit 1
fi

# Create the Nginx configuration file
cat <<EOF > $CONFIG_PATH
server {
    listen 80;
    #server_name $DOMAIN_NAME;

    location / {
        proxy_pass http://$LB_DNS_NAME;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

# Restart Nginx to apply changes
systemctl restart nginx

echo "Nginx configuration created at $CONFIG_PATH with Load Balancer DNS: $LB_DNS_NAME"
echo "Nginx restarted successfully."
EOF

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "nginx-instance"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "nginxasg" {
  desired_capacity     = 2
  min_size             = 2
  max_size             = 4
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
