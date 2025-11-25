#
# This is to deploy VPC, subnet, RT, IGW and instance

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Config AWS provider

provider "aws" {
  region = "us-east-1"
 # access_key = ""
 # secret_key = ""
}

# Create VPC

resource "aws_vpc" "vpc_auto" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc-auto"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc_auto.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Public_Subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.vpc_auto.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "Private_Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_auto.id
  tags = {
    Name = "IGW"
  }
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.vpc_auto.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-RT"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.RT.id
}

# Create a security group
resource "aws_security_group" "web" {
  name        = "web-access"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.vpc_auto.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-access"
  }
}

resource "aws_instance" "web_server" {
  ami = "ami-0fa3fe0fa7920f68e"
  count = 2
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  associate_public_ip_address = true
  tags = {
    Name = "web-server-${count.index + 1}
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    echo "Hello"
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCeRFYwYeDWNWULi37/yYstuDGANM6cGUK9ZaO91btiUWOEsM2PM/HyvPKKsBL8ySBfJFuuSI4TGeV1E2vOcltBUVy5MsHbFehWTnef26MsKg9uYuxx+4p0bzb4AYrA/usQyhkw0LKEAgEbhACbN3cx5QFd4iZ/W8XdXtd7bcSQ5PNoI2hF7bTvCWAHe9ItHJsnJe4RMwJ1s0hrelutscWlhz6BhR8vJs8Uz3JlVFg35UztDBoERhOBkZ4hq05hb4DWzk72SJjVBLAYloktUYCfEsxiAjGF+2xdLfAQHv4WKRwdZHrFC4zKyNbMVfzBxOh/zM15Uw73FEMfpiRGdzIPn7SU4mZLStEF/MBKDDTeuSUqcPDPrOPivWQTU6XNZRgJSuyIGOnDtdY1fuhaRoujq2X2AtAIP5YZ4ka44H6y2bcDLSwS2huEablbWBz7E2GELoAPiufmCbNFlX2lNCAR9A2iie7DI94mBnu47WxybVm05C5FayiwYI1fhaVkU3s= root@master" >> /home/ec2-user/.ssh/authorized_keys
    echo "key added"
  EOF
}

output "web_servers_ips" {
  description = "Web Servers Public IPs"
  value       = aws_instance.web_servers[*].public_ip
}
