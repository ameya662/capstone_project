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

ENDPOINT=$(aws rds describe-db-clusters \
--query 'DBClusters[?DBClusterIdentifier==`wordpress-cluster`].Endpoint' \
--output text)

# Configure WordPress
sudo sed -i "s/'database_name_here'/'WPDB'/g" /var/www/html/wp-config.php
sudo sed -i "s/'username_here'/'admin'/g" /var/www/html/wp-config.php
sudo sed -i "s/'password_here'/'MySQLadm1n'/g" /var/www/html/wp-config.php
sudo sed -i "s/'localhost'/'$ENDPOINT'/g" /var/www/html/wp-config.php

cat >> wp-config.php << EOF
define('WP_HOME', 'http://globalharmony.publicvm.com');
define('WP_SITEURL', 'http://globalharmony.publicvm.com');
EOF

systemctl restart httpd

exit 

# aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
# aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
# aws configure set region $AWS_DEFAULT_REGION

# aws s3 cp s3://globalharmonybucket/wordpress-backup.tar.gz /tmp/

# tar -xzvf /tmp/wordpress-backup.tar.gz 

# cd /tmp/var/www/html

# sudo cp -rf * /var/www/html

# aws s3 cp s3://globalharmonybucket/db-backup.sql /tmp/

# sudo mysql -h wordpress-cluster.cluster-ctmpvoaw2olz.us-west-2.rds.amazonaws.com -u admin -pMySQLadm1n WPDB < /tmp/db-backup.sql
