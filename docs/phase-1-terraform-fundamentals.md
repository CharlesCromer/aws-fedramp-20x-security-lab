# Phase 1 — Terraform Fundamentals

## Overview

Phase 1 established the Terraform foundation for the AWS FedRAMP 20x Security
Lab.

The objective was to develop hands-on experience with the Terraform workflow,
resource configuration, variables, outputs, reusable modules, infrastructure
state, change detection, deployment, and destruction before using Terraform
as the primary Infrastructure as Code platform for the larger capstone.

This phase used a temporary AWS lab environment and exercised the complete
Terraform lifecycle from configuration through cleanup.

---

## Skills Demonstrated

Phase 1 demonstrated hands-on use of:

- Terraform configuration files
- AWS provider configuration
- Input variables
- Terraform outputs
- Reusable child modules
- Resource dependencies
- `terraform init`
- `terraform fmt`
- `terraform validate`
- `terraform plan`
- `terraform apply`
- Terraform state inspection
- Infrastructure change detection
- In-place resource modification
- `terraform destroy`
- Post-destroy AWS cleanup verification

---

## Terraform Project Structure

The Phase 1 capstone used a Terraform root module and a reusable EC2 child
module.

```text
phase1-capstone\
├── main.tf
├── terraform.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── modules\
    └── ec2\
        ├── main.tf
        ├── variables.tf
        └── outputs.tf

## Infrastructure Implemented

The Phase 1 capstone used Terraform to provision a small AWS environment
consisting of:

- One VPC
- One private subnet
- One security group
- One EC2 instance

The implementation included security-focused configuration such as:

- No automatic public IPv4 assignment on the workload subnet
- No inbound security-group rules
- No public IPv4 address on the EC2 workload
- No public DNS name on the EC2 workload
- IMDSv2 required for the EC2 instance

The environment was intentionally small so the focus remained on Terraform
fundamentals and infrastructure lifecycle management.

---

## Terraform Validation and Planning

The configuration was successfully validated before deployment.

Terraform planning was used to review the proposed infrastructure before
resources were created.

The initial capstone plan identified:

```text
Plan: 4 to add, 0 to change, 0 to destroy.
```

This demonstrated the use of Terraform planning as a pre-deployment review
step rather than making infrastructure changes without first examining the
expected result.

---

## Infrastructure Deployment

Terraform successfully created the four planned AWS resources.

The completed deployment reported:

```text
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

AWS-side verification was then performed to confirm that the resources and
security characteristics defined by Terraform were reflected in the deployed
environment.

---

## Change Detection and Controlled Modification

Phase 1 also demonstrated Terraform's desired-state behavior.

The EC2 instance configuration was deliberately modified, after which
Terraform detected that the existing resource required an in-place change.

The plan reported:

```text
Plan: 0 to add, 1 to change, 0 to destroy.
```

Terraform then successfully applied the modification:

```text
Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

This demonstrated that Terraform can identify configuration differences and
apply controlled infrastructure changes without unnecessarily recreating
resources.

---

## Infrastructure Destruction and Cleanup

At the conclusion of the lab, Terraform was used to remove the complete
environment.

The destruction plan identified:

```text
Plan: 0 to add, 0 to change, 4 to destroy.
```

The operation completed successfully:

```text
Destroy complete! Resources: 4 destroyed.
```

AWS-side verification was subsequently performed to confirm that the lab
resources and associated compute were no longer active.

This cleanup step was important both for infrastructure lifecycle management
and for controlling cloud cost.

---

## Evidence

Curated Phase 1 evidence is stored under:

```text
evidence/phase-1/
├── screenshots/
├── command-output/
└── artifacts/
    └── terraform-source/
```

### Screenshot Evidence

The screenshot set demonstrates the lifecycle in sequence:

1. Terraform project and module structure
2. Successful Terraform validation
3. Initial Terraform plan
4. Successful infrastructure deployment
5. AWS VPC verification
6. AWS private-subnet verification
7. AWS security-group verification
8. AWS EC2 verification
9. Terraform change detection
10. Successful controlled configuration change
11. Successful Terraform destruction
12. Post-destroy cleanup verification

### Command-Output Evidence

Text-based evidence is retained for significant Terraform operations,
including:

- Validation
- Planning
- Initial deployment
- Terraform outputs
- State inspection
- Change detection
- Controlled modification
- Infrastructure destruction

Text output is retained in addition to screenshots because it provides
searchable and reviewable evidence of the actual Terraform execution.

---

## Relationship to the Larger Capstone

Phase 1 focused on learning and demonstrating Terraform fundamentals.

Beginning with Phase 2, Terraform becomes part of a broader cloud-security
engineering workflow:

```text
Terraform Infrastructure as Code
        ↓
AWS security architecture
        ↓
OPA/Rego Policy as Code
        ↓
CI/CD automated validation
        ↓
Machine-readable security evidence
        ↓
NIST SP 800-53 / FedRAMP
        ↓
FedRAMP 20x
        ↓
NIST SP 800-171 / CMMC Level 2
        ↓
DoD RMF relevance
```

The Phase 1 artifacts therefore serve as the foundational IaC evidence for the
larger AWS, Policy as Code, continuous-validation, and cross-framework
traceability project.

---

## Scope Disclaimer

This phase is a personal training and portfolio exercise.

It does not represent a FedRAMP authorization, CMMC certification, formal DoD
RMF authorization package, or assessment of a production system.