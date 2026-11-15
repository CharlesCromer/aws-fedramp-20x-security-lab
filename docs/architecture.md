# Project Architecture

## Overview

The AWS FedRAMP 20x Security Lab is a hands-on cloud security engineering
portfolio project designed to connect Infrastructure as Code, Policy as Code,
automated security validation, evidence generation, and cross-framework
security traceability.

The project will evolve incrementally. Infrastructure will first be defined
with Terraform, followed by automated policy validation, CI/CD integration,
evidence generation, and security-framework mapping.

## Network Security Architecture

Private workloads use Terraform-managed security groups with a default-deny
baseline.

The initial private workload security group contains no ingress rules and no
egress rules. Network access is not enabled by default. Required connectivity
will be introduced explicitly as workload dependencies are identified and
documented.

This design establishes a controlled starting point for workload communication
and ensures that future network paths are deliberate, reviewable, and managed
through Infrastructure as Code.

## Workload Identity Architecture

EC2 workloads use Terraform-managed IAM roles and instance profiles.

The initial workload IAM role trusts only the Amazon EC2 service and begins
without managed or inline identity-based permission policies. The associated
instance profile provides the mechanism for assigning the role to a future EC2
instance.

AWS service permissions are introduced explicitly only when a documented
workload dependency requires them. This separates workload identity from
authorization and establishes a least-privilege starting point for future
workloads.

## Private Workload Architecture

The initial EC2 workload combines the project's private networking,
default-deny security group, and least-privilege IAM identity.

The workload receives no public IPv4 address and begins with no permitted
inbound or outbound security-group traffic. Its IAM instance profile provides
workload identity without initially granting AWS service permissions.

IMDSv2 is required for instance metadata access, and the root EBS volume is
encrypted and configured for deletion when the workload is terminated.

Additional connectivity and permissions will be introduced only as documented
workload requirements are added.

## Development Toolchain

The primary development workflow is:

Visual Studio Code  
→ Integrated PowerShell terminal  
→ Git  
→ GitHub  
→ Terraform  
→ AWS  
→ OPA/Rego  
→ GitHub Actions / CI/CD  
→ Security evidence  
→ Framework mappings

Git operations are intentionally practiced through both the command line and
the Visual Studio Code Source Control interface.

## Repository Structure

```text
aws-fedramp-20x-security-lab\
├── README.md
├── terraform\
│   ├── main.tf
│   ├── terraform.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── modules\
├── policies\
├── tests\
├── mappings\
├── evidence\
├── docs\
│   ├── architecture.md
│   └── decisions.md
└── .gitignore