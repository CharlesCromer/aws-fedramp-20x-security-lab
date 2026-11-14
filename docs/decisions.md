# Project Decisions

This document records major technical, architectural, and workflow decisions
for the AWS FedRAMP 20x Security Lab.

The purpose is to preserve not only what was implemented, but why particular
tools and approaches were selected.

---

## Decision 001 — AWS as the Cloud Platform

**Status:** Accepted

AWS will be the primary cloud platform for this project.

The project intentionally focuses on one cloud provider so that sufficient
depth can be developed in cloud architecture, Infrastructure as Code,
security configuration, automated validation, and compliance evidence
generation rather than spreading the effort across multiple cloud platforms.

---

## Decision 002 — Terraform as Infrastructure as Code

**Status:** Accepted

Terraform will be used as the primary Infrastructure as Code (IaC) tool.

Terraform provides a declarative method for defining AWS infrastructure,
supports reusable modules, enables infrastructure changes to be reviewed
before deployment, and produces machine-readable plans that can later be
used for automated security validation and evidence generation.

---

## Decision 003 — OPA/Rego as Policy as Code

**Status:** Accepted

Open Policy Agent (OPA) and Rego will be used for Policy as Code (PaC).

OPA/Rego will eventually evaluate infrastructure configuration and Terraform
plans against security requirements so that selected security controls can be
tested automatically before deployment.

---

## Decision 004 — Visual Studio Code as the Primary IDE

**Status:** Accepted

Visual Studio Code will be the primary development environment.

The VS Code integrated terminal will use PowerShell.

This provides a single workspace for Terraform development, documentation,
Git operations, policy development, and later CI/CD configuration.

---

## Decision 005 — Learn Git Through Both CLI and GUI Workflows

**Status:** Accepted

Git operations will intentionally be practiced using both:

1. Git commands from the VS Code integrated PowerShell terminal.
2. The VS Code Source Control and GitHub graphical interfaces.

The command-line workflow will be taught first so that the underlying Git
concepts are understood rather than hidden behind graphical abstractions.

The equivalent VS Code GUI workflow will also be used so that both methods
become familiar.

---

## Decision 006 — GitHub as the Remote Repository

**Status:** Accepted

GitHub will host the remote portfolio repository.

Git will provide local version control while GitHub will provide remote
repository hosting and, in later phases, CI/CD automation through GitHub
Actions.

The repository will maintain a meaningful commit history that shows the
project evolving from initial infrastructure through automated security
validation and compliance evidence generation.

---

## Decision 007 — Cross-Framework Security Traceability

**Status:** Accepted

The primary compliance and security mapping path for the project will include:

- NIST SP 800-53
- FedRAMP, primarily the Moderate baseline
- FedRAMP 20x and applicable Key Security Indicators (KSIs)

The project will also maintain secondary cross-framework traceability to:

- NIST SP 800-171
- CMMC Level 2
- DoD Risk Management Framework (RMF)

The intent is not to claim complete compliance or certification with each
framework.

Instead, the project will demonstrate how a single technical security
capability and its associated evidence can support multiple related security
and compliance requirements.

---

## Decision 008 — Evidence Reuse as a Design Goal

**Status:** Accepted

Where practical, security evidence will be generated once and reused across
multiple framework mappings.

The intended relationship is:

Technical capability  
→ Terraform implementation  
→ OPA/Rego validation  
→ CI/CD test  
→ Evidence artifact  
→ NIST SP 800-53  
→ FedRAMP  
→ FedRAMP 20x  
→ NIST SP 800-171 / CMMC Level 2  
→ DoD RMF relevance

This is intended to demonstrate both technical implementation and
cross-framework GRC traceability.

---

## Decision 009 — Default-Deny Workload Security Groups

**Status:** Accepted

Private workload security groups will use a default-deny starting configuration.

The initial workload security group will contain no ingress rules and no egress
rules. Required network connectivity will be added only when a documented
workload dependency justifies the access.

This approach intentionally avoids treating unrestricted outbound connectivity
as an assumed requirement. Instead, network access must be introduced
deliberately through Terraform and reviewed as part of the infrastructure
change process.

The decision supports the project's least-privilege and controlled-connectivity
objectives by:

- Preventing unnecessary inbound exposure.
- Preventing unrestricted outbound connectivity from becoming an implicit
  default.
- Requiring future network access to be justified by an actual workload
  dependency.
- Keeping network-policy changes visible in Terraform plans and Git history.
- Producing evidence showing when and why connectivity is introduced.

The operational consequence is that workloads attached to this security group
will not have network connectivity until the required ingress or egress rules
are explicitly defined.

This restriction is intentional. Future connectivity will be added narrowly
based on documented application or service requirements rather than by enabling
broad default access.

This design decision represents the project's implementation of least-privilege
and controlled-network-access principles. It should not be interpreted as a
claim that FedRAMP specifically requires security groups to contain zero
outbound rules.

---

## Decision 010 — Default-Deny Workload IAM Identity

**Status:** Accepted

Workload IAM identities will begin with no identity-based permissions attached.

The initial EC2 workload IAM role will trust only the Amazon EC2 service through
`sts:AssumeRole`. The role will not initially have managed policies or inline
policies granting access to AWS services or resources.

An IAM instance profile will be created to make the role available for future
EC2 workloads, but the creation of an identity does not by itself justify
granting that identity access.

Required permissions will be introduced only when a documented workload
dependency identifies a specific AWS service, action, and resource that the
workload must access.

This approach supports least privilege by:

- Separating workload identity from workload authorization.
- Avoiding broad permissions based on assumed future requirements.
- Requiring future permissions to be justified by an actual workload dependency.
- Making permission additions visible in Terraform plans and Git history.
- Allowing IAM changes to be independently verified and captured as security
  evidence.

The operational consequence is that a future EC2 instance using this role will
have an AWS identity but will not initially receive identity-based permissions
to access AWS services or resources.

This restriction is intentional. Permissions will be added narrowly as
documented workload requirements are introduced.