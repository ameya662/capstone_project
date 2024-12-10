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
AWS_ACCESS_KEY_ID="ASIA3D2JXZQPJDQ2GG4B"
AWS_SECRET_ACCESS_KEY="M5ZH9QrYlWrvjdv9eJpC5m6QrnjyWYexfhcuELBy"
AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjENL//////////wEaCXVzLXdlc3QtMiJHMEUCIEho1H9qiv++JHkMT42RwTdsXXdJ0XJU/3/flwnPmNpEAiEAzso2NolP5Wn5eSk4ysCdnfi3uXUXSCjeDgD3v8UhzS4qugIIi///////////ARABGgw3NjQxMjE5NTk0NTQiDBzxE67IqGBm8T9lCCqOAiWF/gJTbnTH1chLzgPL+j4V2+g4eI8BOhkEXy5i4VrrruAN7HjmovpF1vM0FuvQx4uW+NSTSd4OxsJm80mJ0/y3Nc1QWfJSkN6SwjGdOBhSCAIJogWEY4C4p/SG+movJqzL3znqSJj7FiWXDz/l/3m4PCThgS0tCabNMnQvYEZtOAPA/MFo+LWh7SdORVlCNO4X7Y2Qxq18QujtAPRKKcA+8dG4rauL4RzUKcLpVi5H7HKuwh6dV/WCy8cC8HEldIDaEztrv9HjsbtElNs35Wvc2lMezTD6tIeEm3OLwkYXT6bsxt+nJhShXHDkcc0EqApV+hmO6Pf58Fl3KNriVywavlifXnc6fdwE8jkOBDD2neC6BjqdAbXZBNuJ+uBHQsAPxQxMWmFPs/3wBAAnnK83DcqCnaHyCMGFKsfETjM/7SnK0k1fWu+BbBpRlG9S8y8WLG9qyqjSYeo+hFmt4BiYrJDdnrOIn0d6MlpswcuNYa1b1E00enRgpI6YqQgej6OXSquO7krkF2tGv+xJfmNxKjMq+d9z340CBInW6A59LMq/8J0iaJ/Z5WAPeLTLgK4V1BE="
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
