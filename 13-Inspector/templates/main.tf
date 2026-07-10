terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = var.aws_region }

resource "aws_inspector2_enabler" "this" {
  account_ids    = [var.account_id]
  resource_types = ["EC2", "ECR"]
}
