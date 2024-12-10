#!/bin/bash
sudo -s
sleep 300
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Set AWS access credentials and region
AWS_ACCESS_KEY_ID="ASIA3D2JXZQPOOBQUJSN"
AWS_SECRET_ACCESS_KEY="E0Lml9TJJSIOGJMEAWK5D3jL++d+sUYgVGXcki+r"
AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjENH//////////wEaCXVzLXdlc3QtMiJGMEQCIB8SkpL/C7C29YaxQWFU4qe4hWL2P0a+AlOvO2qsds1AAiAlHedE31WYH9jub/g7YdSirE3z5TtfrLz5hNgds8aMuiq6AgiK//////////8BEAEaDDc2NDEyMTk1OTQ1NCIMHeLW78QNqlg0mB0gKo4CxVQV/O4CyGpwASLFo4onW9UbClhuS4QKX/5fKqAS3EaMl7a/aNr7hvuOzun39nAwZWWKeFxLNlhS6ONcsqnsgNx1Lf9mQimiSBw5X/4XIZVOdCvIObjNjEI85GgrkS0NNS1LB7tZEe+xB5mc2eq0n5ZUUn31eXselCA0Ji6OAJJJefwYNqQ3j1lP9JDUe2t1gJJIj/1WO0s9mkOlMWQV6F+X2RQzhsvivW4+FKbh57rKiCRAlr/Z8Dz8yWJtcV+lvz2A+5UL3LGek6tnxrKi02mtFgFOxmpPVG8L5LEg9jFpMXwCx5o7JT6F14YOA8tiDNsccJhKy0ai5nYoiyEsMTtzPiE3iBM1yHp7e/cCMMH737oGOp4BpQzF1ui/YLaRmoru7maqnAB8ubslzP8iCRvx4YlYVrZuuGigmgBoaPP4WlMNaQPtEkjZQCT3j0zdstrB7BR9cW6CxYOgY6WY3K4kM7yNtCgdwYiyb+DDKoGB7odb6zmmRs7FJfn7uK1Gh8RoZJxqczR6tSdUb+MBRCoYXEzy1A5PTbBqi34cvqczP1jhLiwsB4M9FW7CySCNCAOo/SI="
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

