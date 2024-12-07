#!/bin/bash
sudo -s
sleep 300
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Set AWS access credentials and region
AWS_ACCESS_KEY_ID="ASIA3D2JXZQPJOZM4K4O"
AWS_SECRET_ACCESS_KEY="3ES+513bS3RxFQJ7rwYgVIsovkrwE6gRzXnRqggM"
AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEJX//////////wEaCXVzLXdlc3QtMiJHMEUCIFpWQtpx+bU36waCUaURFQ6UbTggfc8wc0+cOlwzg40lAiEA+5k+5sUcRrsxkaTe+Z48RTWBrxT4/H5zcKmkZ63QExIqsQIIThABGgw3NjQxMjE5NTk0NTQiDGOzoWC8m41Je4fZWyqOAne6Heuc5hiNK0/Od4umXUk1zcjceZflcL3OaCcZRrV13PUTnzXK1ZVWEILW2rbQxtwUJkdZxQhs7tQXdYJfKwZQeJyvSc+4LqyNYbUtP0QxjSHsD0Zn0/Vkr5X1CvxGVbXdBCFclSkdtlPnb9R8kZp0q0scUkFaVhikclbdH2s0RbAnE1AHvj1lY/4o6Zy0Tj8qhVM7SehG8sTD98SWgkcIMfdUQFY0KA/WrYgRMZ/E24JkqOLst82mGvzhDmmEVKi38rRZvLOf1ta07Gk+0TjuX+bqaF6p/p9p69l+GgGOhsJcjCudt0rW/aVY/eMehz347RJv+DKYy6C8hHEdS6R4JevQhSFDyAyCpxzOyzCX39K6BjqdAa7dDsY7/Jou7Oo/J6u6lnER7untaGxsgb9fq8B2hi6dRE5AiS5E0+0EQg79iHDqH2eXojYTH9CSLeUo42Z1MPmSHD7PWwgNZuOTEHTe1oMfejlNwPJNqkH5D7+0awWsSwFdnZylgw6YPN49Plfhp5xKIMhOxH6QzEWOZv+4ojt+ImCfGgFy1I4D0BHlPOGTG6TRLRQ/muRJ2gf6d9E="
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
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}  
EOF

# Restart Nginx to apply changes
systemctl restart nginx

