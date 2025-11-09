## Random
resource "random_pet" "sg" {
  length    = 2
  separator = "-"
}

## AWS VPC
resource "aws_vpc" "awsec2demo" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-quick_cloud_network"
  }
}

## AWS VPC Subnet (private)
resource "aws_subnet" "awsec2demo" {
  vpc_id                  = aws_vpc.awsec2demo.id
  cidr_block              = "172.16.10.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-quick_cloud_network"
  }
}

## Security Group (allow inbound 8080, all egress)
resource "aws_security_group" "awsec2demo" {
  name   = "${random_pet.sg.id}-sg"
  vpc_id = aws_vpc.awsec2demo.id

  ingress {
    description = "App port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Dedicated ENI with fixed private IP and SG
resource "aws_network_interface" "awsec2demo" {
  subnet_id       = aws_subnet.awsec2demo.id
  private_ips     = ["172.16.10.100"]
  security_groups = [aws_security_group.awsec2demo.id]

  tags = {
    Name = "NI-quick_cloud_network"
  }
}

## EC2 Instance attached to ENI
resource "aws_instance" "awsec2demo" {
  ami           = "ami-0be2609ba883822ec" # us-east-1
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.awsec2demo.id
    device_index         = 0
  }
}
