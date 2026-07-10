terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = var.aws_region }

resource "aws_kms_key" "portfolio_cmk" {
  description             = "Portfolio CMK"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "portfolio_cmk" {
  name          = "alias/portfolio-cmk"
  target_key_id = aws_kms_key.portfolio_cmk.key_id
}

resource "aws_secretsmanager_secret" "db_password" {
  name       = "app/db-password"
  kms_key_id = aws_kms_key.portfolio_cmk.key_id
}
