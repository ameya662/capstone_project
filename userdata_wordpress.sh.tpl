#!/bin/bash
sudo -s
sleep 300
yum update -y
amazon-linux-extras enable php8.0
yum install -y httpd php php-mysqlnd php-cli php-pdo php-fpm php-json php-mbstring php-xml php-common mysql
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
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}

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

cat >> /var/www/html/wp-config.php << EOF
define('WP_HOME', 'http://globalharmony.publicvm.com');
define('WP_SITEURL', 'http://globalharmony.publicvm.com');
EOF

systemctl restart httpd

exit 

sleep 200

export PER_ACCESS_KEY_ID=${PER_ACCESS_KEY_ID}
export PER_SECRET_ACCESS_KEY=${PER_SECRET_ACCESS_KEY}
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}

aws configure set aws_access_key_id $PER_ACCESS_KEY_ID
aws configure set aws_secret_access_key $PER_SECRET_ACCESS_KEY
aws configure set region $AWS_DEFAULT_REGION

aws s3 cp s3://globalharmonybucket/wordpress-backup.tar.gz /tmp/

cd /tmp

tar -xzvf wordpress-backup.tar.gz 

cd var/www/html

sudo cp -rf * /var/www/html

aws s3 cp s3://globalharmonybucket/db-backup.sql /tmp/

sudo mysql -h wordpress-cluster.cluster-ctmpvoaw2olz.us-west-2.rds.amazonaws.com -u admin -pMySQLadm1n WPDB < /tmp/db-backup.sql
