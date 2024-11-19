resource "aws_vpc" "wordpress_vpc" {
    cidr_block = "192.168.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "Wordpress VPC"
        }
}

resource "aws_subnet" "wordpress_subnet" {
    vpc_id = aws_vpc.wordpress_vpc.id
    cidr_block = "192.168.10.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-west-2a"
    tags = {
        Name = "Wordpress Public Subnet"
    }
}