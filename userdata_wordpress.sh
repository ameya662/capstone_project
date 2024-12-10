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

ENDPOINT=$(aws rds describe-db-clusters \
--query 'DBClusters[?DBClusterIdentifier==`wordpress-cluster`].Endpoint' \
--output text)

# Configure WordPress
sudo sed -i "s/'database_name_here'/'WPDB'/g" /var/www/html/wp-config.php
sudo sed -i "s/'username_here'/'admin'/g" /var/www/html/wp-config.php
sudo sed -i "s/'password_here'/'MySQLadm1n'/g" /var/www/html/wp-config.php
sudo sed -i "s/'localhost'/'$ENDPOINT'/g" /var/www/html/wp-config.php

systemctl restart httpd
