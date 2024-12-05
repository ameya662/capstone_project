#!/bin/bash
#sleep 500
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

cat > ~/.aws/credentials << EOF
[default]
aws_access_key_id=ASIA3D2JXZQPATRXBPO6
aws_secret_access_key=o0Q425vvMrSlgrWY5JmnQBuBv2OrWQNXAAPpfCHl
aws_session_token=IQoJb3JpZ2luX2VjEGAaCXVzLXdlc3QtMiJHMEUCIQC23L8MMC4QMhnHdRmfJ+WWMFNftZzCkPUj3BAkBwDKKwIgHk0Iiu6canYgqMnwmfDdvTyhSLw/wiJ25FAyeby15F0qsQIIGRABGgw3NjQxMjE5NTk0NTQiDJTl33NczULsIqp6kCqOAi0VcXNzDGN0maVDot9KdHjsM5Y84Dqnfn/RYMybBUToii/eZG87ycYH/WdI36xiSnv2w6jQACc2eqtB/Ig8BRhBQmEJgtr2C5PVgNj6f+GU1UBzy2UfpK0sIBPBEueXkeXwE0JBQEkNr0H2sMfzbWxmvy5z6CUVg4QChmG1WirodIZqGsMvYjrEYUJ3Lcj2mz6NvcxkiuHOm7a4Zx1xc+DNpiFWd3yqOiYWgbOjMnNB+9b3/KQGIS1ys5IRm1MDRHCQTAAJwwFpSYqsDQBMCbNpgHQASnC+fOwDkubjaL64Jg0Pq/GYimQ8lLMDg2R7EpFwRUxadVZdeu2FGtsAB4Bf0NMKsnJwSpMz1ahgBDCvl8e6BjqdAdt1S4IxmfwGBMsqyemn+sRpApuEMywqdcox+pJN0D2LBOkyPVoflzQZ0Kk8MQrl7tdfeXaLCrqcKpUDqOIkk5wqhtACh9zT8dMfkLK6mpAHSjom/ksdbFOOs7qpawEhUy1/43HkQGsgt8fRc4Kdu6xa2DlFpMHX6InNOAvCkdolnqEPHurXY5CRahO46TZeMrmJghWNrSA3cXTdsjI=
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

