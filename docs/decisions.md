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