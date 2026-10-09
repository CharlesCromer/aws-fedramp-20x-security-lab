# Phase 1 — Terraform Fundamentals

## Status

**Complete**

Phase 1 established the Terraform foundation for the AWS FedRAMP 20x Security
Lab.

The phase included guided HashiCorp Terraform AWS fundamentals work followed
by an independently built Terraform capstone.

The objective was to develop practical proficiency with Terraform and
demonstrate the ability to create, validate, deploy, modify, inspect, and
destroy AWS infrastructure using Infrastructure as Code.

---

## Phase Objective

Develop practical proficiency with Terraform fundamentals and demonstrate the
ability to independently:

- Define AWS infrastructure with Terraform
- Use variables and outputs
- Work with root and child modules
- Understand Terraform state
- Review infrastructure changes before deployment
- Provision AWS resources
- Detect and apply configuration changes
- Destroy infrastructure cleanly
- Verify the resulting AWS state
- Capture useful implementation evidence

---

## Skills Demonstrated

Phase 1 demonstrated hands-on use of:

- Terraform CLI
- HashiCorp Configuration Language (HCL)
- AWS provider configuration
- Terraform resources
- Input variables
- Outputs
- Data sources
- Resource attributes
- Resource references
- Implicit dependencies
- Terraform state
- Terraform Registry research
- Terraform Registry modules
- Locally authored child modules
- Root-module and child-module relationships
- Provider version management
- Module version management
- AWS infrastructure provisioning
- Terraform change detection
- In-place resource updates
- Terraform destroy and cleanup
- Troubleshooting provider/state compatibility
- AWS CLI usage
- AWS Console verification
- Visual Studio Code and PowerShell Terraform workflow

---

## Terraform Workflow Practiced

The Terraform lifecycle practiced during Phase 1 included:

```text
terraform init
terraform fmt
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform state list
terraform output
terraform destroy
```

This workflow established the operating model that will continue throughout
the larger capstone.

---

## Guided Fundamentals Work

Before the independent Phase 1 capstone, Terraform fundamentals were practiced
through guided HashiCorp AWS training.

The guided work included provisioning and managing AWS infrastructure such as:

- A custom VPC
- A public subnet
- Private subnets
- An EC2 instance
- Associated VPC networking resources

This work established familiarity with:

- Terraform configuration
- AWS provider usage
- Terraform Registry resources and modules
- Variables
- Outputs
- State
- Resource references
- Standard Terraform lifecycle commands

Those skills were then applied independently in the Phase 1 capstone.

---

## Independent Phase 1 Capstone

The independent capstone was developed as a separate Terraform project before
its selected source files and evidence were incorporated into the larger
portfolio repository.

The capstone demonstrated the ability to build a small AWS environment without
simply reproducing the guided training configuration.

---

## Terraform Project Structure

The independent Phase 1 capstone used a Terraform root module and a locally
authored EC2 child module.

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
```

The root module defined and coordinated the overall AWS environment.

The EC2 child module encapsulated EC2-specific configuration and received the
values required to deploy the workload into infrastructure created by the
root module.

Sensitive and locally generated files such as `terraform.tfvars`, Terraform
state files, and the `.terraform` working directory are intentionally excluded
from the public evidence package.

A sanitized snapshot of the Phase 1 Terraform source is preserved under:

```text
evidence/phase-1/artifacts/terraform-source/
```

---

## Root Module Responsibilities

The root module created and managed:

- Custom AWS VPC
- Private subnet
- EC2 security group
- Local EC2 child module

Purpose-based Terraform resource naming was used, including:

```text
aws_vpc.main
aws_subnet.private
aws_security_group.ec2
module.ec2
```

---

## Local EC2 Child Module

The locally authored EC2 child module included:

- Required input variables
- EC2 resource definition
- EC2 instance tagging
- IMDSv2 enforcement
- Module outputs

Inputs included values such as:

```text
ami_id
instance_type
subnet_id
security_group_ids
instance_name
project_name
environment
```

Outputs included:

```text
instance_id
private_ip
```

This demonstrated how a root module can provide inputs to a reusable child
module while consuming selected values returned by that module.

---

## Resource Relationships and Dependencies

Terraform references were used to pass AWS-generated resource identifiers
between root-module resources and the EC2 child module.

Examples included:

```text
aws_vpc.main.id
aws_subnet.private.id
aws_security_group.ec2.id
module.ec2.instance_id
module.ec2.private_ip
```

The VPC ID was referenced by resources that depended on the VPC.

The private subnet ID and security-group ID were passed into the EC2 child
module as input values.

The root module consumed selected child-module outputs such as the EC2 instance
ID and private IP address.

These references also established Terraform's implicit resource dependencies.

Terraform therefore determined the necessary creation order from its dependency
graph rather than from the physical order of blocks in the `.tf` files.

---

## Infrastructure Implemented

The independent Phase 1 capstone used Terraform to provision:

- One VPC using `10.20.0.0/16`
- One private subnet using `10.20.1.0/24`
- One EC2 security group
- One Amazon Linux 2023 EC2 instance
- EC2 instance type `t3.micro`

The EC2 workload was deployed into the Terraform-created private subnet and
associated with the Terraform-created security group.

The environment was intentionally small so that the focus remained on
Terraform fundamentals, resource relationships, modules, state, change
management, and infrastructure lifecycle operations.

---

## Security-Focused Configuration

The Phase 1 implementation included several security-conscious configuration
choices.

### Private Subnet

The workload subnet was configured without automatic public IPv4 assignment.

### EC2 Network Exposure

The EC2 workload had:

- No public IPv4 address
- No public DNS name
- A private IPv4 address within the Terraform-created subnet

### Security Group

The Terraform-created security group contained no inbound rules.

This avoided introducing unnecessary inbound network exposure for a workload
that did not require remote access for the purpose of the lab.

### EC2 Instance Metadata Service

IMDSv2 was explicitly required using:

```text
http_tokens = "required"
```

This demonstrated that security-relevant EC2 configuration could be defined
directly in the Infrastructure as Code implementation.

---

## Terraform Validation and Planning

The configuration was successfully validated before deployment.

Terraform planning was then used to review the proposed infrastructure before
resources were created.

The initial independent capstone plan identified:

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

Verification included review of:

- VPC
- Private subnet
- Security group
- EC2 instance
- Network exposure characteristics
- IMDSv2 configuration

This demonstrated the importance of verifying deployed cloud state rather than
assuming successful Terraform execution alone proved the intended result.

---

## Change Detection and Controlled Modification

Phase 1 also demonstrated Terraform's desired-state behavior.

After the initial deployment, the EC2 instance `Name` tag was deliberately
changed from:

```text
phase1-capstone-ec2
```

to:

```text
phase1-capstone-ec2-updated
```

Terraform detected the modification as:

```text
Plan: 0 to add, 1 to change, 0 to destroy.
```

The change was then successfully applied:

```text
Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

The EC2 instance was updated in place rather than replaced.

This demonstrated Terraform's ability to compare current managed
infrastructure with the desired configuration and calculate the minimum
required infrastructure change.

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

The destroyed resources included the:

- EC2 instance
- EC2 security group
- Private subnet
- VPC

Post-destroy verification confirmed that the Phase 1 AWS lab resources and
associated compute were no longer active.

Terraform state was also verified after destruction.

A subsequent `terraform plan` proposed recreating the four resources because
the Terraform configuration still described those resources as the desired
state.

That recreation plan was reviewed but intentionally not applied.

This demonstrated the distinction between:

```text
Terraform configuration  → desired state
Terraform state          → Terraform's managed-resource mapping
AWS                       → actual deployed infrastructure
```

The cleanup process was also important for cloud cost control.

---

## Key Lessons Carried Forward

### Desired State

Terraform configuration defines the desired infrastructure state.

Destroying deployed resources does not change the configuration's declared
desired state.

### Plan Before Apply

`terraform plan` provides a reviewable description of proposed infrastructure
changes before they are implemented.

This allows create, modify, replace, and destroy operations to be examined
before approval.

### State

Terraform state maps Terraform configuration to deployed infrastructure and is
central to Terraform's ability to manage resources over time.

### Variables vs Resource Attributes

A reference such as:

```text
var.instance_type
```

retrieves a value supplied through a Terraform input variable.

A reference such as:

```text
aws_subnet.private.id
```

retrieves an attribute produced by a Terraform-managed resource.

### Modules

Child modules receive values through input variables and expose selected
values through outputs.

The root module controls how the child module is used without directly
managing the child module's internal implementation.

### Dependencies

Terraform determines resource creation order through references and its
dependency graph rather than the physical order of blocks in a `.tf` file.

### Change Detection

Terraform can distinguish between infrastructure operations such as:

- Create
- Update in place
- Replace
- Destroy

The Phase 1 capstone demonstrated both initial creation and a controlled
in-place update.

### Provider Compatibility

Terraform provider versions and Terraform state schemas can be related.

Provider-version changes can therefore affect state compatibility and must be
managed deliberately.

### Naming

Terraform resource labels and module names should describe the purpose or role
of a resource rather than temporary learning context whenever practical.

### Formatting

`terraform fmt` formats Terraform files in the current directory.

`terraform fmt -recursive` also formats Terraform files within nested child
modules.

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

The raw Phase 1 working evidence remains outside the public repository as a
local archive.

---

## Screenshot Evidence

The curated public screenshot set demonstrates the Phase 1 lifecycle in
sequence:

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

The screenshots were reviewed, sanitized where necessary, and annotated to
highlight the evidence most relevant to each stage of the lifecycle.

---

## Command-Output Evidence

Text-based evidence is retained for significant Terraform operations:

```text
terraform-validate-capstone.txt
terraform-plan-capstone.txt
terraform-apply-capstone.txt
terraform-output-capstone.txt
terraform-state-list-capstone.txt
terraform-plan-change-detection.txt
terraform-apply-change.txt
terraform-destroy-capstone.txt
```

Text output is retained in addition to screenshots because it provides
searchable and reviewable evidence of the actual Terraform execution.

---

## Terraform Source Evidence

A sanitized snapshot of the independent Phase 1 Terraform implementation is
retained under:

```text
evidence/phase-1/artifacts/terraform-source/
```

It includes the root Terraform configuration and the locally authored EC2
child module.

The public source snapshot intentionally excludes:

```text
terraform.tfvars
terraform.tfstate
terraform.tfstate.backup
.terraform/
```

These files are excluded because they are either locally generated, may contain
environment-specific values, or are not appropriate for public source control.

---

## Relationship to the Larger Capstone

Phase 1 focused on learning and independently demonstrating Terraform
fundamentals.

Beginning with Phase 2, Terraform becomes one part of a broader cloud-security
engineering and compliance workflow:

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
NIST SP 800-53
        ↓
FedRAMP
        ↓
FedRAMP 20x
        ↓
NIST SP 800-171 / CMMC Level 2
        ↓
DoD RMF relevance
```

The primary framework path for the larger project is:

```text
NIST SP 800-53
        ↓
FedRAMP
        ↓
FedRAMP 20x
```

Secondary cross-framework traceability will also demonstrate relevant overlap
with:

```text
NIST SP 800-171 / CMMC Level 2
DoD RMF
```

The Terraform workflow, AWS provider experience, module concepts,
state-management knowledge, resource dependency model, evidence-capture
process, and infrastructure lifecycle skills developed during Phase 1 serve
as the technical foundation for the remainder of the capstone.

---

## Final Phase 1 Outcome

Phase 1 successfully demonstrated:

- Terraform project organization
- HCL configuration
- Variables
- Outputs
- AWS provider configuration
- AWS resources
- Locally authored Terraform modules
- Root-to-child module input passing
- Child-to-root module outputs
- Resource references
- Implicit dependency management
- Successful validation
- Meaningful execution planning
- AWS deployment
- AWS-side verification
- Terraform state inspection
- Infrastructure modification detection
- In-place change application
- Resource cleanup with `terraform destroy`
- Post-destroy verification
- Evidence capture and curation

Phase 1 is complete.

---

## Scope Disclaimer

This phase is a personal training and portfolio exercise.

It does not represent a FedRAMP authorization, CMMC certification, formal DoD
RMF authorization package, or assessment of a production system.