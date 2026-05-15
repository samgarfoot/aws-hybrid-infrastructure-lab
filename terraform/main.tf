terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

# VPC
resource "aws_vpc" "infra_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "infra-project-vpc"
  }
}

# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "infra-project-public-subnet"
  }
}

# Private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.infra_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "infra-project-private-subnet"
  }
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.infra_vpc.id

  tags = {
    Name = "infra-project-igw"
  }
}

# Route table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.infra_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "infra-project-public-rt"
  }
}

# Associate route table with public subnet
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security group
resource "aws_security_group" "web_sg" {
  name        = "infra-project-sg"
  description = "Allow HTTP, HTTPS and SSH"
  vpc_id      = aws_vpc.infra_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["82.33.113.183/32"]
    description = "SSH access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "infra-project-sg"
  }
}

# EC2 instance
resource "aws_instance" "web_server" {
  ami                    = "ami-082a528a66e6c9fb8" 
  instance_type          = "t4g.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "infra-project-key"

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<html><body><h1>Infra Project — Terraform Deployed</h1><p>Provisioned automatically via Terraform IaC</p><p>VPC: Custom 10.0.0.0/16</p><p>Subnet: Public 10.0.0.0/24</p></body></html>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "infra-project-terraform-server"
  }
}

# Output the public IP
output "web_server_ip" {
  value       = aws_instance.web_server.public_ip
  description = "Public IP of the web server"
}

