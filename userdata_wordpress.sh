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

# Configure WordPress
cat > /var/www/html/wp-config.php <<EOF
<?php
define('DB_NAME', 'WPDB');
define('DB_USER', 'admin');
define('DB_PASSWORD', 'MySQLadm1n');
define('DB_HOST', "${aws_rds_cluster.wordpress_cluster.endpoint}");
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
define('FS_METHOD', 'direct');
define('WP_DEBUG', false);
if (!defined('ABSPATH')) {
    define('ABSPATH', dirname(__FILE__) . '/');
}
require_once ABSPATH . 'wp-settings.php';
EOF

amazon-linux-extras enable php8.0
yum clean metadata
yum install php-cli php-pdo php-fpm php-mysqlnd php-json php-mbstring php-xml php-common

systemctl restart httpd

tags = {
    Name        = "WordPress-Instance-${count.index + 1}"
    Environment = "Project"
}
