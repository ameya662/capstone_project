#!/bin/bash
sudo -s
sleep 300
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Set AWS access credentials and region
AWS_ACCESS_KEY_ID="ASIA3D2JXZQPHMUUQ4XV"
AWS_SECRET_ACCESS_KEY="RxRqro1lHPyK7LIIDizkYFOLPYQNMpayQ/E74OX5"
AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEJb//////////wEaCXVzLXdlc3QtMiJIMEYCIQCtcTyw7UoW+XKx+YPRSDBm7XUa+YJYnmYKl/XDAy0sJwIhALVP1L68BPOC9eFhGCfNJ6iaF9kUcnQlwJ1EV4s4mxoGKrECCE8QARoMNzY0MTIxOTU5NDU0IgzrXS/Ijv0ShQtPyUUqjgKAEshse9+VHn9x3588lji41kHwiHvozAXRQIF6VpSM62epAvRmd4uAispi2qv6cvnRpr9R3CIDzSk6xV1Q7/MEfRWAVlrU+YCe1OLJ6dGPIzZ5Vs7uTIxRDIt19D1lRlAD6h1MZO7CKRXoximiMBZ/+F2XmZEB7B2KGLQOOKTao5T/4nLead09FXZbgpdTNs8P5z2SsoU3dE8brsVwRRaZY7DQc3BzhgICsIlx9lhIT7J+ziWQczC6E4bEjTuUA/Q2MAqVpjIfP2g0+HsWO3qcDTVaTnL3bAmzYAQDEqEAxuIEzJiwcVSh/ny4K3oPhTrP7ARTNGjIjH4p/iV/B+xhTLvYOlDLcmznGhWGfDYwg4vTugY6nAHMcROYj45Hj9OCgCtyY4GEz9w5plIW8kO+c/w15aM1aFrMmcSBaDR6GANv3NWX5wC/yxo1FL4H2/4YLg3s9kEZjxsAgrs1+YhxlCi5qO89p7Gb+3RoN44AxWB9ibKxcGZh4LPQtcDC6l99btndtRzIA+VX3+0I8p0Dd7id40A7ouAU6WijgECpftLVfU1buDP5dtJoRjOx4ENkKDE="
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

