#!/bin/bash
sudo -s
sleep 300
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Set AWS access credentials and region
AWS_ACCESS_KEY_ID="ASIA3D2JXZQPCEOOYZ32"
AWS_SECRET_ACCESS_KEY="LBbb9Hwf2VnlRQ+BtRnDxqS3GAbBmJCnIvHO87Ft"
AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEMX//////////wEaCXVzLXdlc3QtMiJGMEQCIE3ce8kzu4SIx7vHG1SSH8lyESxxbBryPfnE6RWz0TMZAiB0SdH3AMLTWMAFPO09mJsoYib181dQRaXxAci7/RNOKSqxAgh+EAEaDDc2NDEyMTk1OTQ1NCIM+SUTA70Y22gEykEeKo4CKz+tISik1is3iDmHfik1mYZkFe1qCtpM1oBEPidoimLANzf9NCUbkP30yTWMSK6OewQhjc3SqqBxCW23lvtnYU6wXL2VV9FJQKuYwmLqOgwzbQWN/j394H8LBvOpmlfMvU+RMbYbbcN7jg3Swwbi6SIH4QNjRAuxVpDaAtnLzELOTCpSZBGC1Ch3sWD3QQc574fStVkGxJtfXJdwVnAEL8IymmP6prYqgXrkMkrRsNyUHd3j9jcrbxTZhdN0d1R/kc2/VTC9Y0SU+GIhC9vZSv/FD2mg8zw1fWWARErqBxTPjXFrx6smA/lzYeTiYh0Uvnoq5xvE8IMKG50LVPIPmG44a5DzvQgiH44mU+bnMK2x3boGOp4BN8tt6FDpj4IBH5PgymzdFll4ZWu5QUIw8LDWuUE9y6JfLfRG4dzNOuiQ2rdNAgmK9+ovrTMz+TGJBV0O2uWcUF1i0iOJFeAI0yjJNA1Ml4TlOnekg989lRVriK/DA4l/r69VYn8nG6nrtGasca6B52KaMtwnZAVfnw6m+jWXd7/m2EjAnHQqxxGUw1WVK4w596IHJbMu9eknyssOUpk="
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

