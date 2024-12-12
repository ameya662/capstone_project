#!/bin/bash
sudo -s
sleep 300
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Set AWS access credentials and region
AWS_ACCESS_KEY_ID="ASIA3D2JXZQPD72PQUTH"
AWS_SECRET_ACCESS_KEY="RGuZCn1VPrvHiLA9qTobXIOPr4z9tnCD/F9/xHsX"
AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEAoaCXVzLXdlc3QtMiJIMEYCIQD1lV54kF/OsJaxYTsYNi07TvLyTBkbjM0Nnws7y4kTogIhALV1LH1DKwwEY8wjZBxaeNJ1q3OVj4e6ozAl65S3Z3p5KroCCMP//////////wEQARoMNzY0MTIxOTU5NDU0IgxgOiwpN6nIF0FEgl4qjgK0enwpzzCcMFdhbTbJyLepbpbj6hzbq/4T7w9v8C76Ip50DtpwAoivq2iNO5hlaBH1JWHaD2/de9547WSPWZ1z10KT7mKug30/TgrWfM/bdmw0X5MX6vzY9wY9qMT15myGCH8JTXjCtvpk2Luy9lP9SGSsrg+0yHxwnyX5BJLuEWbVZ0ifXJY6bDfNk+Wg7cQQcA0p8j7PXdd4LVXoaVf4pobPUMlm3pEjHQGB2JGNsxBbDXQWNgTLoESZeNq4EoRY6jAF1qxgRpjLx8S7NWfnvkLWfmkBfMGx/eKUN2a0tgW8BhAG7tn49PAsn2RLN5NyolpDy81ggvTyrNjUR0pGrvWqEyfNEvXfwN/duJEwtMzsugY6nAGK/SvwOTll2IaWOSTrfJ10GtMTtoEbEnu1AcDH5SUHLOJjM7j4LmMNkC/RV8OeH+piAwsGc8NMo1yjqIBWoqnJYHMla7PSfCbrjruCDiFTIpwMxzL6kub2mr8KtU0MN0A8E7xJIbozfClY2AX7bcGyA1QFo5LQxeO/Ow5bN02Wanwvk88mWtgP3IZRXgDpHh5CzmiZIzqL9xFIalg="
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

