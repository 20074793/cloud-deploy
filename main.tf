#########################################################
#  Terraform – Automated AWS EC2 Deployment (Free Tier)
#  Part 1: Infrastructure Setup for B9IS121 Assignment
#  Author: Nipun Siriwardana
#########################################################

# -------------------------------------------------------
#  Specify Terraform and AWS provider version
# -------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.0"
}

# -------------------------------------------------------
#  Configure AWS Provider
# -------------------------------------------------------
provider "aws" {
  region = "eu-north-1"   # Stockholm (Free Tier eligible)
}

# -------------------------------------------------------
#  Security Group – Allow SSH and HTTP
# -------------------------------------------------------
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow SSH (22) and HTTP (80) traffic"

  # Inbound rules
  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-web-sg"
  }
}

# -------------------------------------------------------
#  Fetch Latest Amazon Linux 2023 AMI (Free Tier)
# -------------------------------------------------------
# Uses AWS Systems Manager (SSM) Parameter Store to get
# the latest Amazon Linux AMI dynamically per region.
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# -------------------------------------------------------
#  EC2 Instance – Amazon Linux 2023 (Free Tier)
# -------------------------------------------------------
resource "aws_instance" "web" {
  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t3.micro"              # Free Tier instance type
  key_name               = "terraform-key"          # Key pair already created in AWS
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name        = "terraform-web-server"
    Environment = "Development"
    Project     = "Automated Container Deployment"
  }
}

# -------------------------------------------------------
#  Outputs – Display Useful Information
# -------------------------------------------------------
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "security_group" {
  description = "Security Group Name"
  value       = aws_security_group.web_sg.name
}
