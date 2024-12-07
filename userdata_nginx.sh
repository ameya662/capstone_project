#!/bin/bash
sudo -s
sleep 300
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Set AWS access credentials and region
AWS_ACCESS_KEY_ID="ASIA3D2JXZQPBCXYUODY"
AWS_SECRET_ACCESS_KEY="qfuOSNVQ+aRe+wQa9IELmECXi54k5TSvVHXopx3b"
AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEJL//////////wEaCXVzLXdlc3QtMiJIMEYCIQCzGDdKS8k4pDtJ+ELKD0R4dxcByG/gze3w9mOJuHH8gAIhAPUOzgpqVQhgdyu8EeJum0jpvlt8JMko5WhAgNFQAlpHKrECCEsQARoMNzY0MTIxOTU5NDU0IgyrY3DIbznSiZ9bPyoqjgLu//4+xvwTUD9LssypIlNPzSvfUBpDB4cvgCzeeoDsi22Hj+aFB3sLITxLDjNApKH5L0AsGGSjBHN9TuI+o5ZqhYFVHCLSj7ZfGJZ4ehCvADc4Rw3urolqjw6RSsEBTJ+FpsZ6SToBJmoIUypwGmsn9+iW4GkTU+56yIg/B6mXOsTnr2NudGueAXtlHxFe8bjR4evIFeYTptruOl8ggq1nxhpft4GERgqwZmBXufXCYVcmx/nqeVuDB7EgW0y4JIvSjvPBQi18VAD+g/sr8Qy0PAK7CkzX/HP6ek7B3mX7OG6setAD1tU7WUyJ7z/8WQIcT3liNQno6wEuHytRoS3cDbPwVEGfcxMxyMC4cpYwiY3SugY6nAHnAs+wAvvA2itnYMtg1Ckcwhd5CWriNu+IWsML1hgd1eWeIf2N/VJelPjaVBx2G5Of0wtimrU2Ipgqj1YE7Jo73i+Cqf0kYXL3HvnGw7HzTvg14HTY0a0SXvrY4V67XOaW10H9yRZGG5kFl+cH7Eh2MgZ0Pv/cL+LhbGsf9v7SVMTbRg+gZBAUwZaNBktysBeZmMcLO8TS8SpmaLk="
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

