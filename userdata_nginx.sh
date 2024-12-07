#!/bin/bash
sudo -s
sleep 300
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Set AWS access credentials and region
AWS_ACCESS_KEY_ID="ASIA3D2JXZQPE62WGOJN"
AWS_SECRET_ACCESS_KEY="wRhtapm/iWNgZXVq41Bub+1P6OOr6M1ctYR6VY6V"
AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEJT//////////wEaCXVzLXdlc3QtMiJIMEYCIQDDW8jk1lxWE3k/4tbRXEKWnvs1SB14cxlbmoaVlMLnYAIhAIqZZ4Zf3WY/0a5RCAbDfqE5gpPbbGC+U2DZ+4WWSnnVKrECCE0QARoMNzY0MTIxOTU5NDU0IgyimCNG8hwFUw/XRLkqjgJdArAXfim/Ui0LTKATPuIRY+mG5ihwDs2PEOEmJDOWAyU5yZpn9yyaLnpw8tA+/If/aFAZ7U15NTH0XNEfa00b7Z2hBy1rvYbWHynczVuzepyIS4o9GPAeK/eOAQp0by4Qkvhy5nuTS9K4LpQLBOBier7GhDpAxLyWe2f8awuuq811Ly/XEn4ALapiWydAQ3swAZTO0Zcm9N2wEI7BQYPjWB/nxfe40lfhus1lXk1sRyr2IvGMabQ0VMm1DMZtqSgOO+s7tW/h9XXRXDiSXu2ys3cIXB8c0PbiAN0pRF50l1RlTz97/k3ZDTgbp1Y49deBcgCwX/OWcJruAEn1LXrbd2224G1TxaaEbbfx/kQw+sDSugY6nAEYR0KP88I5/5VTShIdBexfzCJf9omF9ZxAtBMSX7SktNo3/iokepDowDYQNVX8NPUvG6oH0LVwMLcd+hvfgwD2MyAJG8UfT8wXvdk6E8nYTP1/RBhgpnTctn8F8MQ8psau5EzFa+MRtkJW1gT4egjmMGdkoJJTViunNowUocjBK4Qp1eCt4AFugwbstkPc57gjIH/U9uEsJIpyfA0="
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

