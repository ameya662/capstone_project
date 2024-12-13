#!/bin/bash
sudo -s
sleep 300
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Set AWS access credentials and region
AWS_ACCESS_KEY_ID="ASIA3D2JXZQPOSLIC3RL"
AWS_SECRET_ACCESS_KEY="L8m6/OgFzmgyoLbHdDFzPz21fhquU7EV+dyd8gYq"
AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEBIaCXVzLXdlc3QtMiJIMEYCIQDqVusu4wLvj8ZSDEkTqmUwhymMKQUaLobIMoxZpMOWcAIhAItqatoQYzdV0Wr+26ariczY0s3v/bkRs6mA+pOusCTfKroCCMv//////////wEQARoMNzY0MTIxOTU5NDU0IgyLZI7AgvemvWuha5wqjgLUDnYcWo/vtC4Gc+/99yr67C6SWGZXfmM+kJH6wnsJwfKSg8UC5U/rYkPNBksSR3ADMZ9YromKYhr2pJzzGSQr06GrPmjnb1gV0Xdavh/+4f8CAZJR4MuyGe3AM0JKkljlbvGI6oPuQAHrWrp8XyejEXeuku+4pxWyu4oY1B/MJk2Ly34mGSKNM+ObbIcw3tOwA7WI6RuDmdlc4+UxVkwtDrxv6erfr9X+27C8C+FSFLmzQJGYJByjGzN+5IYd5mcNRr3897QlwxGlUDqdC5pCSEY9REjb4Pzjly4duRIPnTFa0KzLOaSoL39UQIoHZ5JWzcIPOJ1E++FEevBhSlnLG66QLbzJtsUYIlAF1N0w3ZjuugY6nAEPTJxG4q2qeUd2wSl8lt5FF/NItALlcMkX4DHNVIxtnYWw403DOX2oitZDBid8jqL9dH31WT99hUv5liJh4TZ0u38gaFapHWGxKXtqFpKcQ5AuPLPR/JpVdp3gP9CtPhcXyd1gRWkwDe6Eb46z0OOTMD44i9dy3mrZbLAdgXn5NocyKCt7JypMHBmEdY5Q3llgikJYeH9bIv4HSdM="
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

