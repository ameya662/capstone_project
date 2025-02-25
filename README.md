Capstone Project

This project automates the deployment of a web application infrastructure using Terraform. It sets up a Virtual Private Cloud (VPC) with public and private subnets, configures security groups, and deploys NGINX and WordPress instances along with an RDS database.

Architecture

The infrastructure includes:

VPC: Custom VPC with public and private subnets across multiple availability zones.

Internet Gateway: Allows public traffic into the VPC.

NAT Gateway: Enables instances in private subnets to access the internet.

Security Groups: Define inbound and outbound traffic rules for NGINX, RDS, and WordPress instances.

NGINX: Reverse proxy server deployed in the public subnet.

WordPress: Content management system deployed in the private subnet.

RDS: Managed relational database service for WordPress.

Prerequisites

Terraform: Ensure Terraform is installed on your machine.

AWS Credentials: Configure your AWS credentials to allow Terraform to provision resources.

Usage

Clone the Repository:

git clone https://github.com/ameya662/capstone_project.git
cd capstone_project

Initialize Terraform:

terraform init

Review and Modify Variables:

Inspect the variables.tf file and adjust any variables as needed.

Plan the Deployment:

terraform plan

Review the execution plan to understand the resources that will be created.

Apply the Deployment:

terraform apply

Confirm the prompt with 'yes' to begin provisioning.

File Structure

main.tf: Primary Terraform configuration file.

providers.tf: Specifies provider configurations.

variables.tf: Contains variable declarations.

vpc.tf: Configurations for VPC and subnets.

net_igw.tf: Configures the Internet Gateway.

net_nat.tf: Configures the NAT Gateway.

subnets.tf: Defines public and private subnets.

sg_nginx.tf: Security group for NGINX instances.

sg_rds.tf: Security group for RDS instances.

sg_wordpress.tf: Security group for WordPress instances.

lb_nginx.tf: Load balancer configuration for NGINX.

lb_wordpress.tf: Load balancer configuration for WordPress.

lb_rds.tf: Load balancer configuration for RDS.

userdata_nginx.sh.tpl: User data script template for NGINX setup.

userdata_wordpress.sh.tpl: User data script template for WordPress setup.

Notes

User Data Scripts: The userdata_nginx.sh.tpl and userdata_wordpress.sh.tpl files contain initialization scripts for NGINX and WordPress instances, respectively. Ensure these scripts are correctly configured before deployment.

Resource Management: Be mindful of AWS resource usage to avoid unnecessary costs. Remember to destroy the infrastructure when it's no longer needed:

terraform destroy

This command will remove all resources defined in your Terraform configuration.
