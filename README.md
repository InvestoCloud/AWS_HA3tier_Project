# Project 2: Terraform IaC for Highly Available AWS Architecture

## Overview

This project converts the manually built AWS architecture from Project 1 into reusable Terraform Infrastructure as Code.

The goal of this project is to demonstrate how production-style cloud infrastructure can be deployed consistently, versioned through Git, reviewed before changes are applied, and reused across environments.

Project 1 was built manually in the AWS Console to understand the core AWS services. Project 2 rebuilds that same architecture using Terraform modules.

---

## Business Problem

Manual cloud deployments are slow, inconsistent, and difficult to reproduce. A company needs a repeatable way to deploy its AWS web application platform across environments without relying on manual console clicks.

The infrastructure must be:

- Repeatable
- Version controlled
- Modular
- Environment-aware
- Easier to review before deployment
- Safer to update over time

---

## Solution Summary

I created a Terraform project that provisions a highly available AWS web architecture using reusable modules.

The Terraform code creates a custom VPC, public and private subnets, an Application Load Balancer, EC2 instances in an Auto Scaling Group, an RDS database in private subnets, security groups, CloudWatch dashboards, CloudWatch alarms, and SNS notifications.

---

## Architecture

Internet Users
     |
     v
Application Load Balancer
Public Subnets
     |
     v
EC2 Auto Scaling Group
Private App Subnets
     |
     v
Amazon RDS
Private Database Subnets
     |
     v
CloudWatch Monitoring and SNS Alerts

---

## Security Groups Module

The security groups module creates the layered network access controls for the application architecture.

### Security Groups Created

- ALB security group
- EC2 application security group
- RDS database security group

### Traffic Flow

Internet → ALB SG → EC2 App SG → RDS SG

---

## ALB Module

The ALB module creates the public entry point for the application architecture.

### Resources Created

- Application Load Balancer
- Target Group
- HTTP listener on port 80
- Health check configuration using `/health`

### Traffic Flow

Internet → Application Load Balancer → Target Group → EC2 App Instances

## WAF Protection

AWS WAF was added in front of the Application Load Balancer to inspect incoming web requests before they reach the private application instances.

### Resources Created

- AWS WAFv2 Web ACL
- AWS Managed Common Rule Set
- AWS Managed Known Bad Inputs Rule Set
- Basic IP-based rate limit rule
- WAF association with the Application Load Balancer

### Traffic Flow

```text
User → Route 53 → AWS WAF → HTTPS ALB → EC2 App Instances → RDS