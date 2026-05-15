# Security Controls Documentation

## Overview

This document details the security controls implemented in the AWS hybrid 
infrastructure environment, mapped to the NIST Cybersecurity Framework and 
CIS Critical Security Controls v8.

---

## 1. Network Segmentation

**Control:** Custom VPC with public and private subnets  
**CIS Control:** 12 — Network Infrastructure Management  
**NIST CSF Function:** Protect  

**Implementation:**
- VPC CIDR: `10.0.0.0/16`
- Public subnet: `10.0.0.0/24` — internet-facing resources only
- Private subnet: `10.0.1.0/24` — no internet gateway route
- Internet gateway attached to public subnet only
- Explicit route tables controlling traffic flow

**Rationale:** Network segmentation limits the blast radius of a compromise. 
Resources in the private subnet cannot be directly reached from the internet, 
even if the public subnet is compromised.

---

## 2. Least Privilege SSH Access

**Control:** SSH restricted to authorised IP address  
**CIS Control:** 6 — Access Control Management  
**NIST CSF Function:** Protect  

**Implementation:**
- Security group ingress rule for port 22 restricted to `/32` (single IP)
- Default AWS security group allowed `0.0.0.0/0` — explicitly remediated
- Applied via Terraform ensuring configuration is version controlled

**Rationale:** Unrestricted SSH access is one of the most common attack 
vectors against cloud infrastructure. Restricting to a known IP eliminates 
brute force exposure entirely.

---

## 3. IAM Least Privilege

**Control:** Dedicated IAM user with scoped permissions  
**CIS Control:** 5 — Account Management  
**NIST CSF Function:** Protect — Identity Management  

**Implementation:**
- Root account access keys deleted
- IAM user `infra-project-admin` created with PowerUserAccess policy
- IAM management actions explicitly excluded from user permissions
- Verified — AccessDenied response confirmed on IAM operations

**Rationale:** Root account credentials provide unlimited access with no 
restriction. Using a scoped IAM user limits the impact of credential compromise.

---

## 4. MFA Enforcement

**Control:** MFA enabled on all accounts  
**CIS Control:** 6 — Access Control Management  
**NIST CSF Function:** Protect  

**Implementation:**
- MFA enabled on root account via authenticator app
- MFA enabled on `infra-project-admin` via authenticator app
- Console access requires MFA token on every login

**Rationale:** MFA prevents account takeover even if credentials are 
compromised, implementing a core zero trust principle.

---

## 5. S3 Public Access Block

**Control:** Account-level S3 public access restriction  
**CIS Control:** 3 — Data Protection  
**NIST CSF Function:** Protect — Data Security  

**Implementation:**
- BlockPublicAcls: true
- IgnorePublicAcls: true
- BlockPublicPolicy: true
- RestrictPublicBuckets: true

**Finding:** Default AWS configuration had no public access block configured 
at the account level — identified and remediated.

**Rationale:** S3 misconfiguration is one of the most common causes of cloud 
data breaches. Account-level blocking prevents any bucket being inadvertently 
exposed.

---

## 6. Centralised Logging

**Control:** Dual logging architecture  
**CIS Control:** 8 — Audit Log Management  
**NIST CSF Function:** Detect  

**Implementation:**
- AWS CloudWatch agent deployed on EC2
- Three log groups: system logs, auth logs, Nginx access logs
- Filebeat shipping logs to local Elasticsearch
- Kibana dashboard providing real-time log visibility
- 5,500+ log events ingested during testing

**Rationale:** Without centralised logging, security incidents cannot be 
detected or investigated. Dual architecture provides both cloud-native 
visibility and cross-environment SIEM correlation.
