#!/bin/bash
sudo -s
sleep 300
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Set AWS access credentials and region
AWS_ACCESS_KEY_ID="ASIA3D2JXZQPASKNYLAI"
AWS_SECRET_ACCESS_KEY="mefmu4yrCfwpK5t5Kb0aiqrRjOUDJ4/ygGdJDYCK"
AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEMb//////////wEaCXVzLXdlc3QtMiJHMEUCIQD371Zutt7cq+y9JNQ/lRUvZu3Vz8CWNeT9+l4Dfwst0QIgCJz9JXxRE5WwJ49DcHbb2YJQ2YNfAMiyRoKPZhpphfMqsQIIfxABGgw3NjQxMjE5NTk0NTQiDK7M5GTGRZikKnp9CCqOAibq3a9GdIY63YTQ1pUcW/yg4XbaesHvQnPvRpf5xXGa4MxdfRyY4d7pvuSXx9a8kkzM61xJB4XvDwhYY/3VUmCJnsovJ2hts5SGLGuRlJdN+PIjErxd5/WLg4J9sdIaHjl0OCkao+idUpvx45cGFl9W/3W/3SMrKDw71DW9O76i80mBfH4l34xz4s+XM2By0pdqQPXtog6T0KRsP4D61D7Rk3R23zjKY15sa1jzIa1QF4emNBAJLqLr5otrKurr/hojYGd2OUuT8wj0N+FY//n/qYP9aXCaMZ+vuIQC2iiN0LyB+QU3JL1lsHkfeP9x1tvEFi7z+LoF5+EcEoYbccVZOshGR1NUr9NKmZfxcDDyzd26BjqdAWk3MV/G/L0piyn7EsUC8EvcswQtVx685KLgwooU6qsUSkuFPJ7Xv6CFlQ7GoBvAKAP8FOOmEciHLQ75ndxpu9fIijCIaHDa3rS//RvLfvsnth4D5tx9xixaDOtG40Nh6xJQmnYzsiDla7K5qnQB0zmt9Mi67DaPSfxfR3zvavAX7/B6xxFSzJXjj/K46SCjdXo7gqEqaPtWQRNb4uk="
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

