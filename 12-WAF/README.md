# Project: AWS WAF & Shield

## Objective
Protect a web application from common web exploits and DDoS activity using AWS WAF and Shield.

## Services Used
- AWS WAF
- AWS Shield Standard
- Application Load Balancer / CloudFront
- CloudWatch

## Architecture
- Application Load Balancer (or CloudFront distribution) fronting the web application
- WAF Web ACL attached to the ALB/CloudFront distribution
- AWS Managed Rule Groups (Core rule set, SQLi, known bad inputs)
- Rate-based rule to throttle high-request-rate sources
- Shield Standard providing baseline DDoS protection

![Architecture Diagram](./architecture.svg)

## Implementation Steps

**1. Deploy the app behind an ALB**

*Console:*
  - EC2 console → **Load Balancers** → **Create load balancer** → Application Load Balancer → note its ARN

*CLI:*
```bash
# Application-specific — deploy your ALB/target group as normal, then note the ARN
```

**2. Create a Web ACL**

*Console:*
  - WAF console → **Web ACLs** → **Create web ACL** → Region: match your ALB's region → name `portfolio-waf`

*CLI:*
```bash
aws wafv2 create-web-acl --name portfolio-waf --scope REGIONAL --default-action Allow={} --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName=portfolioWaf
```

**3. Add AWS Managed Rule Groups**

*Console:*
  - WAF console → Web ACL → **Add rules** → **Add managed rule groups** → enable `AWSManagedRulesCommonRuleSet` and `AWSManagedRulesSQLiRuleSet` → Save

*CLI:*
```bash
# Managed rule groups are typically added via console or a full rules JSON in update-web-acl
```

**4. Add a rate-based rule**

*Console:*
  - WAF console → Web ACL → **Add rules** → **Add my own rules and rule groups** → Rule type: Rate-based → limit 2000 requests / 5 min per IP → Save

*CLI:*
```bash
aws wafv2 update-web-acl --name portfolio-waf --scope REGIONAL --id <WEB_ACL_ID> --lock-token <TOKEN> --rules file://templates/rules-with-rate-limit.json
```

**5. Associate with the ALB**

*Console:*
  - WAF console → Web ACL → **Associated AWS resources** tab → **Add AWS resources** → select your ALB

*CLI:*
```bash
aws wafv2 associate-web-acl --web-acl-arn <WEB_ACL_ARN> --resource-arn <ALB_ARN>
```

**6. Test the SQLi rule**

*Console:*
  - Send a request with `' OR '1'='1` in a query parameter from your browser/Postman → confirm a 403 Forbidden response

*CLI:*
```bash
curl -i "https://your-alb-dns/?q=' OR '1'='1"
```

**7. Review sampled requests**

*Console:*
  - WAF console → Web ACL → **Sampled requests** tab → filter by Allowed/Blocked

*CLI:*
```bash
aws wafv2 get-sampled-requests --web-acl-arn <WEB_ACL_ARN> --rule-metric-name portfolioWaf --scope REGIONAL --time-window StartTime=<epoch>,EndTime=<epoch> --max-items 50
```

## Security Considerations
- Common web exploits (SQLi, XSS) blocked before reaching the application.
- Rate-based rules mitigate basic application-layer DDoS/brute-force attempts.
- Shield Standard provides always-on network/transport layer DDoS protection at no extra cost.

## What I Learned
How WAF rule evaluation order works, the difference between managed and custom rules, and how Shield Standard complements WAF for layered protection.

## Result
Implemented a layered defense in front of a web application, blocking common exploit patterns and abusive traffic.

## Repository Contents
- `README.md` — this file
- `templates/` — Terraform / CloudFormation / IAM policy JSON (if applicable)
- `screenshots/` — AWS Console screenshots (optional)
- `architecture.svg` — architecture diagram (included)

---
*Part of my [AWS Cloud Security Portfolio](../README.md).*
