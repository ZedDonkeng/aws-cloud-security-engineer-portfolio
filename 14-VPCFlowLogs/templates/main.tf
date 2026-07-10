terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = var.aws_region }

resource "aws_s3_bucket" "flow_logs" {
  bucket = var.flow_logs_bucket_name
}

resource "aws_flow_log" "vpc" {
  vpc_id               = var.vpc_id
  traffic_type          = "ALL"
  log_destination_type  = "s3"
  log_destination        = aws_s3_bucket.flow_logs.arn
}
