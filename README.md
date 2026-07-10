# AWS Cloud Security Engineer Portfolio

A hands-on portfolio of 15 projects demonstrating practical AWS Cloud Security Engineering skills across networking, identity, logging, monitoring, compliance, infrastructure as code, vulnerability management, and incident response.

Built to demonstrate readiness for **AWS Cloud Engineer / Security Engineer** roles.

## About This Portfolio

Each project below is self-contained in its own folder with:
- A detailed `README.md` — objective, architecture, **step-by-step commands (AWS CLI + console)**, security considerations, lessons learned
- `architecture.svg` — a diagram of the project's architecture
- `templates/` for Terraform / CloudFormation / IAM policy code (fill in with your own code as you build each project)
- `screenshots/` for AWS Console evidence (optional — add your own as you complete each lab)

## Projects

| # | Project | Skills Demonstrated |
|---|---------|----------------------|
| 1 | [Secure Multi-Tier VPC](./01-Secure-VPC) | VPC, subnets, route tables, NAT Gateway, Security Groups, NACLs |
| 2 | [IAM Security Best Practices](./02-IAM-Security) | IAM users/roles, MFA, permission boundaries, least privilege |
| 3 | [CloudTrail Logging & Monitoring](./03-CloudTrail) | CloudTrail, CloudWatch Logs, event history, alerting |
| 4 | [GuardDuty Threat Detection](./04-GuardDuty) | GuardDuty findings, investigation, remediation |
| 5 | [AWS Security Hub Dashboard](./05-SecurityHub) | Aggregated findings, compliance standards |
| 6 | [AWS Config Compliance](./06-AWSConfig) | Config rules, compliance monitoring, auto-remediation |
| 7 | [S3 Security Project](./07-S3Security) | Bucket policies, encryption, versioning, Block Public Access |
| 8 | [KMS Encryption Lab](./08-KMS) | Customer-managed keys, encrypting S3/EBS/Secrets Manager |
| 9 | [EC2 Hardening](./09-EC2Hardening) | Secure EC2, IAM roles, SSM Session Manager, patching |
| 10 | [Terraform AWS Infrastructure](./10-Terraform) | Secure infrastructure as code with Terraform |
| 11 | [CloudFormation Secure Deployment](./11-CloudFormation) | Infrastructure as code with CloudFormation |
| 12 | [AWS WAF & Shield](./12-WAF) | Web application protection from common attacks |
| 13 | [Amazon Inspector Vulnerability Assessment](./13-Inspector) | Vulnerability scanning, CVE triage |
| 14 | [VPC Flow Logs Analysis](./14-VPCFlowLogs) | Network traffic capture and analysis |
| 15 | [Incident Response Simulation](./15-IncidentResponse) | GuardDuty alert investigation, NIST IR lifecycle |

## Folder Structure

```
aws-cloud-security-engineer-portfolio/
│
├── 01-Secure-VPC/
│   ├── README.md
│   ├── architecture.svg
│   ├── templates/
│   └── screenshots/
├── 02-IAM-Security/
├── 03-CloudTrail/
├── 04-GuardDuty/
├── 05-SecurityHub/
├── 06-AWSConfig/
├── 07-S3Security/
├── 08-KMS/
├── 09-EC2Hardening/
├── 10-Terraform/
├── 11-CloudFormation/
├── 12-WAF/
├── 13-Inspector/
├── 14-VPCFlowLogs/
└── 15-IncidentResponse/
```

## Core Areas Covered

- **Networking & Isolation** — VPC design, subnetting, routing, flow logs
- **Identity & Access** — IAM least privilege, MFA, permission boundaries
- **Logging & Monitoring** — CloudTrail, CloudWatch, centralized alerting
- **Threat Detection** — GuardDuty, Inspector, Security Hub
- **Compliance** — AWS Config, CIS Benchmark, automated remediation
- **Data Protection** — S3 hardening, KMS encryption
- **Infrastructure as Code** — Terraform, CloudFormation
- **Application Protection** — WAF, Shield
- **Incident Response** — NIST-aligned investigation and remediation runbooks

## How to Use This Repository

Each numbered folder is independent — start with whichever project is most relevant to the role you're applying for. Every project README follows the same format, with real AWS CLI commands, so it's easy for a reviewer to compare skills across projects and see exactly how each thing was built.

## Contact

*Add your name, LinkedIn, and email/contact info here.*
