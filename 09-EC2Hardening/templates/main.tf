terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = var.aws_region }

resource "aws_iam_role" "ec2_app_role" {
  name = "ec2-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_app_profile" {
  name = "ec2-app-profile"
  role = aws_iam_role.ec2_app_role.name
}

resource "aws_security_group" "hardened" {
  name   = "hardened-sg"
  vpc_id = var.vpc_id
  # No inbound SSH/RDP rule — access is via SSM Session Manager only
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "hardened" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.hardened.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_app_profile.name
  tags = { Name = "hardened-instance" }
}

resource "aws_ssm_patch_baseline" "prod" {
  name             = "prod-baseline"
  operating_system = "AMAZON_LINUX_2"
  approval_rule {
    approve_after_days = 7
    patch_filter {
      key    = "CLASSIFICATION"
      values = ["Security"]
    }
  }
}
