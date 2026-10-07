# Project Architecture

## Overview

The AWS FedRAMP 20x Security Lab is a hands-on cloud security engineering
portfolio project designed to connect Infrastructure as Code, Policy as Code,
automated security validation, evidence generation, and cross-framework
security traceability.

The project will evolve incrementally. Infrastructure will first be defined
with Terraform, followed by automated policy validation, CI/CD integration,
evidence generation, and security-framework mapping.

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