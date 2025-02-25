# Capstone Project

This project automates the deployment of a web application infrastructure using Terraform. It sets up a Virtual Private Cloud (VPC) with public and private subnets, configures security groups, and deploys NGINX and WordPress instances along with an RDS database.

## Architecture

The infrastructure includes:

- **VPC**: Custom VPC with public and private subnets across multiple availability zones.
- **Internet Gateway**: Allows public traffic into the VPC.
- **NAT Gateway**: Enables instances in private subnets to access the internet.
- **Security Groups**: Define inbound and outbound traffic rules for NGINX, RDS, and WordPress instances.
- **NGINX**: Reverse proxy server deployed in the public subnet.
- **WordPress**: Content management system deployed in the private subnet.
- **RDS**: Managed relational database service for WordPress.

## Prerequisites

- **Terraform**: Ensure Terraform is installed on your machine.
- **AWS Credentials**: Configure your AWS credentials to allow Terraform to provision resources.

## Usage

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/ameya662/capstone_project.git
   cd capstone_project
