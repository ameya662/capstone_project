# Capstone Project

This project automates the deployment of a web application infrastructure using Terraform. It sets up a Virtual Private Cloud (VPC) with public and private subnets, configures security groups, and deploys NGINX and WordPress instances along with an RDS database. The prominent thing about this infrastructure is that it consists of 2 ALBs (Application Load Balancer). Instead of solely leveraging the in-built load balancing capability, NGINX is used in addition as a reverse proxy, and this NGINX instance is part of the ALB group. Secondly, the WordPress application is part of the other ALB group in the private subnet.

## Architecture

The infrastructure includes:

- **VPC**: Custom VPC with public and private subnets across multiple availability zones.
- **Internet Gateway**: Allows public traffic into the VPC.
- **NAT Gateway**: Enables instances in private subnets to access the internet.
- **Security Groups**: Define inbound and outbound traffic rules for NGINX, RDS, and WordPress instances.
- **NGINX**: Reverse proxy server deployed in the public subnet.
- **NGINX ALB**: To scale up the NGINX appliance
- **WordPress**: Content management system deployed in the private subnet.
- **WordPress ALB: To scale up the WordPress application
- **RDS**: Managed relational database service for WordPress.
- **S3**: Backup storage. Hosted on another cloud account.
- **External DNS**: To use a human friendly URL to access the website hosted on a WordPress
- **New Relic Monitoring**: To monitor the instrastructure

![AWS Architecture](https://github.com/ameya662/capstone_project/blob/main/AWS.jpeg)

