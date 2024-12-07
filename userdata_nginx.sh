#!/bin/bash
sudo -s
sleep 200
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

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

