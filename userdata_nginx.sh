#!/bin/bash
#sleep 500
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

cat >  << EOF
[default]
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

