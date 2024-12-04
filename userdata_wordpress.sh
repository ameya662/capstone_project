#!/bin/bash
sleep 100 s
# Fetch the Bastion instance ID dynamically using its tag or name
PROXY_INSTANCE_NAME="nginx-instance"  # Replace with the name or tag of your Bastion instance
AWS_REGION="us-west-2"                  # Replace with your AWS region

# Fetch the private IP of the Bastion instance using AWS CLI
PROXY_IP=$(aws ec2 describe-instances \
  --region "$AWS_REGION" \
  --filters "Name=tag:Name,Values=$PROXY_INSTANCE_NAME" "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].PrivateIpAddress" \
  --output text)

# Ensure the Bastion IP is fetched successfully
if [[ -z "$PROXY_IP" || "$PROXY_IP" == "None" ]]; then
  echo "Error: Could not fetch the Bastion IP address."
  exit 1
fi

# Set proxy variables
export http_proxy="http://$PROXY_IP:3128"
export https_proxy="http://$PROXY_IP:3128"
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

