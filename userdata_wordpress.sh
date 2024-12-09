#!/bin/bash
sudo -s
sleep 300
yum update -y
amazon-linux-extras enable php8.0
yum install -y httpd php php-mysqlnd php-cli php-pdo php-fpm php-json php-mbstring php-xml php-common
systemctl enable httpd
systemctl start httpd

# Install WordPress
curl -O https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html
sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# Set AWS access credentials and region
AWS_ACCESS_KEY_ID="ASIA3D2JXZQPEWRERB2T"
AWS_SECRET_ACCESS_KEY="4rBA1fZMs3dmEJw2FHo1o8GBfxB+nisoiiauwKEa"
AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEMf//////////wEaCXVzLXdlc3QtMiJIMEYCIQCk5Y1SzeCCrYLe14yB0JQiGp8Im1/05WzYNuryalE7mwIhAI1FBz1w0FyVHtgvoFHiIRSMOCabhs7MRDiukDeTLIvKKroCCID//////////wEQARoMNzY0MTIxOTU5NDU0Igyl5DUEQweknWH3P5kqjgIjPU6VZnex+5sEYYVCRtF3ArK+IaJR0jHoG1qkDL36uVtFAMY5VaNPDQaisTrcwApCYSlN6nI27JxVHchAL4Yl/YTRUdmXRi5zFCHBo9dvRmZrvgq5kK4kpn3LV3nMGUbrl0YcqA7ZDLOFFPO8YMrjJ/Q4QhGcwMA4LLvdgxce2Ild55hGAg2s4yPeTTvZDBYxdJ2i3ODe8Zk8XhxW4ELgJBV4S/pqIKsjjAicpWIBA8awEaDCiJdsyA1XLXyFFx7DPXwi6mRnoR/6wV774A884U00kzqqARUeplsAm+7bTdaR/3rr/kiuoZxBPJbSN8y+EQqD0cGvFEj1PpYlz/PQGHXYA/dAFUD7437U3uww2fLdugY6nAHFuGNhKh7vP2HJfpuKD13Jf2ciewxLg0FHL78f+TcT4MDkqv4B2yFT5zFfca9LhQVLmvm2hzohkNZYSmKgQVTjbCMxKEW7ewCkn1sU/WLkg3YHqP/rlg/a2aeJAWQDg/hglowPaRix3nUbg5sceeD+k8Z9qOkTxT+HYKmQWnNZ0pU9HJqAIqiuNHYI9Oxx9p6xGKcZ4jY0yn+8ZY8="
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

ENDPOINT=$(aws rds describe-db-clusters \
--query 'DBClusters[?DBClusterIdentifier==`wordpress-cluster`].Endpoint' \
--output text)

# Configure WordPress
sudo sed -i "s/'database_name_here'/'WPDB'/g" /var/www/html/wp-config.php
sudo sed -i "s/'username_here'/'admin'/g" /var/www/html/wp-config.php
sudo sed -i "s/'password_here'/'MySQLadm1n'/g" /var/www/html/wp-config.php
sudo sed -i "s/'localhost'/'$ENDPOINT'/g" /var/www/html/wp-config.php

systemctl restart httpd
