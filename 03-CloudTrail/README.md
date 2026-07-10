# Project: CloudTrail Logging & Monitoring

## Objective
Enable comprehensive account activity logging and set up monitoring for suspicious API activity.

## Services Used
- AWS CloudTrail
- Amazon S3
- CloudWatch Logs
- CloudWatch Alarms
- SNS

## Architecture
- Organization/account-wide CloudTrail trail logging to a dedicated S3 bucket
- CloudTrail log file validation enabled for integrity checking
- CloudTrail integrated with CloudWatch Logs for real-time analysis
- CloudWatch Alarms + SNS topic for notification on sensitive API calls (e.g., root login, IAM changes)

![Architecture Diagram](./architecture.svg)

## Implementation Steps

**1. Create the S3 bucket for logs**

*Console:*
  - S3 console → **Create bucket** → name `my-cloudtrail-logs-<account-id>`
  - **Block Public Access settings** → keep all 4 boxes checked (default) → Create bucket

*CLI:*
```bash
aws s3api create-bucket --bucket my-cloudtrail-logs-<ACCOUNT_ID>
aws s3api put-public-access-block --bucket my-cloudtrail-logs-<ACCOUNT_ID> --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

**2. Create a multi-region trail**

*Console:*
  - CloudTrail console → **Trails** → **Create trail**
  - Name `org-trail`, enable for all regions, select the S3 bucket created above, enable **log file validation** → Create

*CLI:*
```bash
aws cloudtrail create-trail --name org-trail --s3-bucket-name my-cloudtrail-logs-<ACCOUNT_ID> --is-multi-region-trail --enable-log-file-validation
aws cloudtrail start-logging --name org-trail
```

**3. Send logs to CloudWatch Logs**

*Console:*
  - CloudTrail console → select `org-trail` → **Edit** → **CloudWatch Logs** section → enable, create/select a Log Group and IAM role → Save

*CLI:*
```bash
aws logs create-log-group --log-group-name CloudTrail/OrgTrail
aws cloudtrail update-trail --name org-trail --cloud-watch-logs-log-group-arn <LOG_GROUP_ARN> --cloud-watch-logs-role-arn <ROLE_ARN>
```

**4. Create a metric filter for root usage**

*Console:*
  - CloudWatch console → **Log groups** → `CloudTrail/OrgTrail` → **Metric filters** tab → **Create metric filter**
  - Pattern: `{ $.userIdentity.type = "Root" }` → name `RootAccountUsage`

*CLI:*
```bash
aws logs put-metric-filter --log-group-name CloudTrail/OrgTrail --filter-name RootUsage --filter-pattern '{ $.userIdentity.type = "Root" }' --metric-transformations metricName=RootAccountUsage,metricNamespace=CloudTrailMetrics,metricValue=1
```

**5. Create an alarm tied to SNS**

*Console:*
  - SNS console → **Topics** → **Create topic** → name `security-alerts` → create an **email subscription** and confirm it via the email link
  - CloudWatch console → **Alarms** → **Create alarm** → select the `RootAccountUsage` metric → threshold ≥ 1 → notify the SNS topic

*CLI:*
```bash
aws sns create-topic --name security-alerts
aws sns subscribe --topic-arn <TOPIC_ARN> --protocol email --notification-endpoint you@example.com
aws cloudwatch put-metric-alarm --alarm-name RootUsageAlarm --metric-name RootAccountUsage --namespace CloudTrailMetrics --statistic Sum --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --alarm-actions <TOPIC_ARN>
```

**6. Repeat for IAM and Security Group changes**

*Console:*
  - Repeat the metric-filter + alarm steps above with patterns for `CreatePolicy`, `AttachRolePolicy`, and `AuthorizeSecurityGroupIngress` events.

*CLI:*
```bash
# Same pattern as step 4-5, changing the filter-pattern and metric/alarm names accordingly
```

**7. Validate**

*Console:*
  - Log in with the root account (or simulate) → check your email within a few minutes for the alert
  - CloudTrail console → **Event history** → search for the event to confirm it was captured

*CLI:*
```bash
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=ConsoleLogin
```

## Security Considerations
- CloudTrail bucket blocks public access and uses SSE-KMS encryption.
- Log file validation enabled to detect log tampering.
- Alerts configured for root account usage and unauthorized changes.

## What I Learned
How CloudTrail captures management and data events, how to pivot from a CloudTrail log entry to a real-time CloudWatch alert, and why centralized logging is foundational to incident response.

## Result
Achieved full visibility into account API activity with automated alerting on high-risk actions.

## Repository Contents
- `README.md` — this file
- `templates/` — Terraform / CloudFormation / IAM policy JSON (if applicable)
- `screenshots/` — AWS Console screenshots (optional)
- `architecture.svg` — architecture diagram (included)

---
*Part of my [AWS Cloud Security Portfolio](../README.md).*
