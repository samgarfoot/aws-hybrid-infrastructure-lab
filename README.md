# AWS Hybrid Infrastructure Lab

## Overview

This project documents the design, deployment, and security hardening of a 
hybrid cloud infrastructure environment built on AWS. The environment mirrors 
real enterprise architecture, combining an on-premise Windows 11 Pro endpoint 
with cloud infrastructure provisioned entirely through Terraform infrastructure 
as code.

The project demonstrates practical knowledge of cloud networking, security 
architecture, least privilege access control, and security monitoring — 
aligned to the NIST Cybersecurity Framework and CIS Critical Security Controls.

---

## Architecture

## Architecture Diagram

<img width="561" height="881" alt="aws-architecture" src="https://github.com/user-attachments/assets/a7d1cf61-5392-4ec5-8c42-dc439e7e86c4" />

---
### On-Premise Environment
- Windows 11 Pro virtual machine (UTM on macOS)
- Hybrid connectivity to AWS cloud environment
- CIS benchmark hardened — see [CIS Hardening Lab](https://github.com/samgarfoot/Cyber-Security-Monitoring-Incident-Analysis-Lab)

### Cloud Environment (AWS eu-west-2 London)
- Custom VPC (`10.0.0.0/16`) replacing default AWS VPC
- Public subnet (`10.0.0.0/24`) — internet-facing resources
- Private subnet (`10.0.1.0/24`) — isolated internal resources
- Internet Gateway with explicit route table configuration
- Security groups with least privilege ingress rules
- EC2 instances running Ubuntu 24.04 ARM64
- Nginx web service deployed and configured

### Security Monitoring
- Elastic Stack (Elasticsearch + Kibana) — centralised SIEM
- Filebeat shipping system and authentication logs
- AWS CloudWatch — cloud-native log collection across three log groups:
  - System logs
  - Authentication logs
  - Nginx access logs

---

## Infrastructure as Code

The entire cloud environment is defined and provisioned using Terraform, 
implementing infrastructure as code principles to ensure:

- Repeatable and consistent deployments
- Version-controlled infrastructure changes
- Auditable provisioning history
- Rapid environment rebuild capability

See the full Terraform configuration in the [terraform/](./terraform/) folder.

---

## Security Controls Implemented

### Network Security
- Custom VPC with network segmentation — public and private subnets
- Sensitive resources isolated in private subnet with no internet route
- SSH access restricted to authorised IP only (CIS Control 6)
- Security groups configured with explicit least privilege ingress rules

### Identity and Access Management
- Root account access keys deleted — root account used only for break-glass scenarios
- Dedicated IAM user (`infra-project-admin`) created with scoped PowerUserAccess policy
- MFA enforced on all AWS accounts (CIS Control 5)
- Principle of least privilege applied — IAM management actions explicitly restricted

### Data Protection
- S3 public access blocked at account level across all four settings (CIS Control 3)
- No public buckets permitted by policy

### Security Monitoring and Logging
- CloudWatch agent deployed on EC2 instances
- Three log groups configured — system, authentication, and web access logs
- Elastic Stack SIEM deployed locally — 5,500+ log events ingested
- Dual logging architecture — cloud-native (CloudWatch) and centralised SIEM (Elastic)
- Implements NIST CSF Detect function

### Security Automation
- N8N security automation workflow deployed
- Simulates SOAR capability — webhook triggered alert processing pipeline
- Demonstrates automated incident response principles

---

## NIST CSF Mapping

| Control Implemented | NIST CSF Function | CIS Control |
|---|---|---|
| VPC network segmentation | Protect | Control 12 |
| SSH restricted to authorised IP | Protect | Control 6 |
| IAM least privilege | Protect | Control 5 |
| MFA enforcement | Protect | Control 6 |
| S3 public access blocked | Protect | Control 3 |
| CloudWatch logging | Detect | Control 8 |
| Elastic Stack SIEM | Detect | Control 8 |
| Security automation workflow | Respond | Control 17 |

---

## Tools and Technologies

- **Cloud:** AWS (EC2, VPC, IAM, S3, CloudWatch)
- **IaC:** Terraform v1.15
- **OS:** Ubuntu 24.04 LTS ARM64
- **Web Server:** Nginx
- **SIEM:** Elastic Stack (Elasticsearch 8.13, Kibana 8.13, Filebeat 9.4)
- **Automation:** N8N workflow automation
- **CLI:** AWS CLI, SSH
- **On-Premise:** Windows 11 Pro (UTM on macOS M1)

---

## Key Learnings

- Default AWS configurations require deliberate hardening — root access keys, 
public S3 access, and permissive security groups are common misconfigurations
- Infrastructure as code dramatically improves deployment consistency and 
auditability compared to manual provisioning
- A dual logging architecture (CloudWatch + SIEM) provides both cloud-native 
visibility and centralised cross-environment correlation
- Network segmentation through public and private subnets is a fundamental 
security architecture principle that limits blast radius in the event of compromise
- Least privilege access control must be implemented deliberately — AWS defaults 
to broad permissions which require active restriction
