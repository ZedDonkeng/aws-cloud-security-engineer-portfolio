terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = var.aws_region }

resource "aws_guardduty_detector" "this" {
  enable = true
}

resource "aws_sns_topic" "security_alerts" {
  name = "security-alerts"
}

resource "aws_cloudwatch_event_rule" "guardduty_high_severity" {
  name = "guardduty-high-severity"
  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail      = { severity = [{ numeric = [">=", 7] }] }
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  rule = aws_cloudwatch_event_rule.guardduty_high_severity.name
  arn  = aws_sns_topic.security_alerts.arn
}
