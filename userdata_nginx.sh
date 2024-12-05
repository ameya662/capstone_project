#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

cat > ~/.aws/credentials << EOF
[default]
aws_access_key_id=ASIA3D2JXZQPE6CCP7BD
aws_secret_access_key=YbwQBCwohVHHST76A2VdL8Yo+SLtMe7dIbhT68jv
aws_session_token=IQoJb3JpZ2luX2VjEF8aCXVzLXdlc3QtMiJHMEUCIDesDvKMFTAlFT5J/e3l2Pgw+Qf1jv5/JTdAF5F9AwX/AiEAxPKywPqnIxWmH32Nc2dwjPj38Jk8kHhz0TJoDkgK/LQqsQIIGBABGgw3NjQxMjE5NTk0NTQiDOeOrx+wVsE0SXbFiiqOAlvgSH9CmOZeH/k9BocvfIIEcWHRGvYcC7sleuiev4Fm1Q7xcEOjW9MjfXQIKzpiGPag/Veo4/CI8GURGQz76JFhfiFxu43gliUJhWIlClB70EwudS/esgm/+fAQD4Hda8CSHsZu0ZC2s3YWp1Dvo3imrOS7Hwt+50qRTt0ylRO+PzjTDADz+49fA3qf7wcRdfczG9RHP0P2KyONaycO9pC5dvwfXRqknHB963DDkZVX6jwECjYj6dO9KQqHORwReXmrfw7CvAgIK9MBCaRwwVYoBWbwuuiE8ZgfWLNO4PbDpV6UpACaIw0GFZwJDZ/qnv3iV6IHvvqeDp0tJ8TuviGzdWziF7IFsuYtjd0hgTCWiMe6BjqdASUEuLu1je+4l3XUafM2Vy7wF1adB03/ePu7OWUzq1E4gYMi4RzSxi0SBiAPun0LEFHfh0JlzgD8IV7n2vJ4eoIlvgcHysnZp2V4P/2tSOHrPI67/X2qdZqcr1GDMBlUzp8/jwkQXVeVr0NYv9rZUnHTv0wBWtclzTwJv7dl6m0RjuQMBpcaxNrEu+CI0nOSh6cJDs71lYZ8p0flbIU=
EOF

# Fetch the private DNS name of the load balancer using AWS CLI
LB_DNS_NAME=$(aws elbv2 describe-load-balancers \
  --names "WordPressALB" \
  --region "us-west-2" \
  --query "LoadBalancers[0].DNSName" \
  --output text)

# Create the Nginx configuration file
sudo cat > /etc/nginx/conf.d/wp.conf << EOF
server {
    listen 80;

    location / {
        proxy_pass http://$LB_DNS_NAME;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

# Restart Nginx to apply changes
systemctl restart nginx

