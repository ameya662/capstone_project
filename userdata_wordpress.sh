#!/bin/bash
sudo -s
sleep 300
yum update -y
yum install -y httpd php php-mysqlnd
systemctl enable httpd
systemctl start httpd

# Install WordPress
curl -O https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html
sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

ENDPOINT=$(aws rds describe-db-clusters \
--query 'DBClusters[?DBClusterIdentifier==`wordpress-cluster`].Endpoint' \
--output text)

# Configure WordPress
sudo sed -i "s/'database_name_here'/'wordpress'/g" wp-config.php
sudo sed -i "s/'username_here'/'wordpressuser'/g" wp-config.php
sudo sed -i "s/'password_here'/'password'/g" wp-config.php
sudo sed -i "s/'localhost'/'$ENDPOINT'/g" wp-config.php

amazon-linux-extras enable php8.0
yum clean metadata
yum install php-cli php-pdo php-fpm php-mysqlnd php-json php-mbstring php-xml php-common

systemctl restart httpd
