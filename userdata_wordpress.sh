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

ENDPOINT=$(aws rds describe-db-clusters \
--query 'DBClusters[?DBClusterIdentifier==`wordpress-cluster`].Endpoint' \
--output text)

# Configure WordPress
sudo sed -i "s/'database_name_here'/'WPDB'/g" /var/www/html/wp-config.php
sudo sed -i "s/'username_here'/'admin'/g" /var/www/html/wp-config.php
sudo sed -i "s/'password_here'/'MySQLadm1n'/g" /var/www/html/wp-config.php
sudo sed -i "s/'localhost'/'$ENDPOINT'/g" /var/www/html/wp-config.php

systemctl restart httpd
