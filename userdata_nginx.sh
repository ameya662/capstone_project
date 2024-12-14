#!/bin/bash
sudo -s
sleep 300
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Set AWS access credentials and region
AWS_ACCESS_KEY_ID="ASIA3D2JXZQPIQHVX4XV"
AWS_SECRET_ACCESS_KEY="sgcWk/JtvGkiTETlmSyVpfmkhvnbIFcEEMvTSAPi"
AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEDwaCXVzLXdlc3QtMiJHMEUCIHk7gheIMaqf72DZbFbTlqUG8rg6pRs1LGbCKdMCp0+aAiEA/Qn5i648eYtW4AQ2sDZEyHOc7DHwQxO7R7Jq8CSoIfoqugII9f//////////ARABGgw3NjQxMjE5NTk0NTQiDP5F6XRFOvcPohg4+CqOAmuhQltJL2YLGYRyLUS68lHKhC9wQhkR1hqHZnz3YJR8VYW/P9FUKgmkbSB5qvwuhOMT2SqYIooH0Zzd30DascKX/h8f7rGbeYSi5q5KTluuoyfiZFaYZr3rtLsRDFBSu2l9vt4ARyUWFF5/afKE4Vf7DU1Yq9+vrpowXUdbvPYq4aPTc+kgCCJhAphCyJ583kgIlSADlmMr+dW13ismimSzYZtcag7MqSkzSVnQgOlRpypCmkqL/bRBBhsnKU+pS0pje5cp3f1+PELvG18xUF7Z5biBCtJT2jeKKJk3gV7xohQ12KFGJtqphnsydcY+Plub5rx7pS/KGwf8MXILb/rk9AbIFEMzrQCCFRhWtTCfwve6BjqdAXHpo8uJBDVNPXGUkxHpbLJ4bSJp5WVwpujhjC2Jd3noB+/utvKYEqp2iZ5cEXfg3r7esV2NKKlmpl5/0+q0R5NwQVva5cHKJDCw5Kc4W/wF8xw2/0gGxRGZadq8uEuMgonf9/HvVDhE3/QNNkxoiGAdAcpbVq+cucjGTn7Wi4f/3YBpL94tGCCUpoGXgvEZldKXFDUOu5SCUqRMbnk="
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

