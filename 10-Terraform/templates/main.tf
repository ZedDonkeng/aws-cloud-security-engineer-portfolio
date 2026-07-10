terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = var.aws_region }

module "vpc" {
  source   = "./modules/vpc"
  cidr_block = var.vpc_cidr
}

module "ec2" {
  source             = "./modules/ec2"
  subnet_id          = module.vpc.public_subnet_id
  security_group_id  = module.vpc.public_sg_id
  ami_id             = var.ami_id
}
