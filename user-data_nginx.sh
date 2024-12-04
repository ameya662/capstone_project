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
