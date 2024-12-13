#!/bin/bash
sudo -s
sleep 300
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Set AWS access credentials and region
AWS_ACCESS_KEY_ID="ASIA3D2JXZQPBICC2WUX"
AWS_SECRET_ACCESS_KEY="cDY47NZwbt+ZN8wqd6fbIReVCMJHyxP4J5/dRJ/1"
AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjECEaCXVzLXdlc3QtMiJGMEQCICNuHcRO7jt3khQ89an8vg2FwNfM7D9kDJN/x55o//XKAiAdCmI+gktyRDUpu3KUm6p14/3XYg1TeTyD10/DPAVsXSq6Agja//////////8BEAEaDDc2NDEyMTk1OTQ1NCIM7hNXm3OR7oSblFahKo4CoiZjtYa9kg//v2wWOYMCSumZmWEQRvyjsF4ufmvW8lVxeo0jhBghfOx6h3r26VqzdSJohnV496RIVtx+C5fDTTHoWZavjQabscdgGWj48L+0bzPhV/i0COaaUG5hdj/ucRbfUxXWZgprXxo5tNU7n6/EossM2eAgGDb5pVLJegr1QtwLsNo2tlOPk1xaSDVzANw03nrZOauqQ3qUHW37/Bu+E17FpP3/eN1rGotzeBB3GexsLHi9Tzlc5MiKV6zg4PkMmijtZZ/Bjxy9hRtiPAcamjxmbXz0wagU0csG/P10ff5U8xIK0kKFi3xfFModfMUCXGSnyPgu65Uu0f9uN4lk+JqyStKa4nc29VH9MJ/T8boGOp4BkyVikrzsTA3SQ9ebQT2kSTwFtDq29RQ3Y2tK34QXMKgBxXVe4w4wJfu8c0zS7+cOqaNxkcWmQGjjrRp0XyCGWJ45/F5QBx1bU61qbxP3vMN0HskzmPe+p7NS4+99vu5YjPBuMDDR2l+8ZI1ofzckCUMaf3cCQEEPiQYnpoBit4QxnQSu34UeJsiQe/TzgckTm/0MokX9m1gkpi7XQeQ="
AWS_DEFAULT_REGION="us-west-2"

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

