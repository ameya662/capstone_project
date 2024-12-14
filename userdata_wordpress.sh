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
AWS_ACCESS_KEY_ID="ASIA3D2JXZQPIQHVX4XV"
AWS_SECRET_ACCESS_KEY="sgcWk/JtvGkiTETlmSyVpfmkhvnbIFcEEMvTSAPi"
AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEDwaCXVzLXdlc3QtMiJHMEUCIHk7gheIMaqf72DZbFbTlqUG8rg6pRs1LGbCKdMCp0+aAiEA/Qn5i648eYtW4AQ2sDZEyHOc7DHwQxO7R7Jq8CSoIfoqugII9f//////////ARABGgw3NjQxMjE5NTk0NTQiDP5F6XRFOvcPohg4+CqOAmuhQltJL2YLGYRyLUS68lHKhC9wQhkR1hqHZnz3YJR8VYW/P9FUKgmkbSB5qvwuhOMT2SqYIooH0Zzd30DascKX/h8f7rGbeYSi5q5KTluuoyfiZFaYZr3rtLsRDFBSu2l9vt4ARyUWFF5/afKE4Vf7DU1Yq9+vrpowXUdbvPYq4aPTc+kgCCJhAphCyJ583kgIlSADlmMr+dW13ismimSzYZtcag7MqSkzSVnQgOlRpypCmkqL/bRBBhsnKU+pS0pje5cp3f1+PELvG18xUF7Z5biBCtJT2jeKKJk3gV7xohQ12KFGJtqphnsydcY+Plub5rx7pS/KGwf8MXILb/rk9AbIFEMzrQCCFRhWtTCfwve6BjqdAXHpo8uJBDVNPXGUkxHpbLJ4bSJp5WVwpujhjC2Jd3noB+/utvKYEqp2iZ5cEXfg3r7esV2NKKlmpl5/0+q0R5NwQVva5cHKJDCw5Kc4W/wF8xw2/0gGxRGZadq8uEuMgonf9/HvVDhE3/QNNkxoiGAdAcpbVq+cucjGTn7Wi4f/3YBpL94tGCCUpoGXgvEZldKXFDUOu5SCUqRMbnk="
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

cat >> /var/www/html/wp-config.php << EOF
define('WP_HOME', 'http://globalharmony.publicvm.com');
define('WP_SITEURL', 'http://globalharmony.publicvm.com');
EOF

systemctl restart httpd

exit 

AWS_ACCESS_KEY_ID="AKIAQ4J5YK4RSC3LLUMS"
AWS_SECRET_ACCESS_KEY="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"
AWS_DEFAULT_REGION="us-west-2"

aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set region $AWS_DEFAULT_REGION

aws s3 cp s3://globalharmonybucket/wordpress-backup.tar.gz /tmp/

cd /tmp

tar -xzvf wordpress-backup.tar.gz 

cd var/www/html

sudo cp -rf * /var/www/html

aws s3 cp s3://globalharmonybucket/db-backup.sql /tmp/

sudo mysql -h wordpress-cluster.cluster-ctmpvoaw2olz.us-west-2.rds.amazonaws.com -u admin -pMySQLadm1n WPDB < /tmp/db-backup.sql
