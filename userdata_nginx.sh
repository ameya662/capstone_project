#!/bin/bash
sudo -s
sleep 300
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Set AWS access credentials and region
AWS_ACCESS_KEY_ID="ASIA3D2JXZQPCE6JRRCX"
AWS_SECRET_ACCESS_KEY="neZY7NsAGHOa6BV8VI7qDpXuwO5g5hMSebj1tttN"
AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEMP//////////wEaCXVzLXdlc3QtMiJHMEUCIQC6xzsxxo2D5JyhT01/1mYc+8VZCYz7n+xnrB2ta4WCzwIgJZmjwYAgZ+QsCmM/7OE0ujargCpIXw4h4H2saDfkSu0qsQIIfBABGgw3NjQxMjE5NTk0NTQiDEZ+0uJL9u1Su9adZiqOAmT+McLEWz3DN1qQvWhjew7NERsrEqIzjzYm4ESuoISyAvu9XmRN/diHvZr2GB9USV3nABp5jQaXSVt0KUBdyy8D/t1wIJSbdoD/16p82uWVFLWTycYUifNn3LLgzSzoxkuhuPkGe5xuIq+/EWiLtUog2SHEJ6dm/u9PcgL6nOfUpDNLCRfIUrhNgekfdsBizVHv/u/NHrh5y7Bgq7vn+9BFoKe5gzpTJpNeQZy0SDnQLMN2OhJQz68Ji+1jXiRgD0YP2zeLwRX6L+f0m9L/58ZjHbW9kR1fCT4Hqhdw8DlequlsYcDhQPWnErSr7HvzP4Rjy0VTUYg2Iz1kxXA+R8bxegZZVe0rh3edzP/30DCU7ty6BjqdAV/4R4yTXEOI+1iB4SqebBtdAX9bWGxGfAZMjZ6zHS1tDKBL5WecwUkAO38sNUsag6sfmP8B29kZsnOcQ+sqAL2pEMKON75oxhgOI8Wewi/Fu+NhdhFvQTuPnBEQZ0Ic7/6XaVoYMkspquIf/76n1Sj5IRNc6lvq3923093Z2AGy4NpMk7RBbUfMOdyX/gRTTAhr/uWkMp33xAn6NBY="
AWS_DEFAULT_REGION="us-west-2"  # Change to your preferred region

# Set AWS CLI configuration
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set region $AWS_DEFAULT_REGION

cat > ~/.aws/credentials << EOF
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
aws_session_token = $AWS_SESSION_TOKEN
EOF

# Fetch the private DNS name of the load balancer using AWS CLI
LB_DNS_NAME=$(aws elbv2 describe-load-balancers \
  --names "WordPressALB" \
  --region "us-west-2" \
  --query "LoadBalancers[0].DNSName" \
  --output text)

cat > /etc/nginx/conf.d/default.conf << EOF
server {
    listen 80;
   # server_name 34.212.55.22;

    location / {
        proxy_pass http://$LB_DNS_NAME:80;
        proxy_ssl_verify off;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}  
EOF

# Restart Nginx to apply changes
systemctl restart nginx

