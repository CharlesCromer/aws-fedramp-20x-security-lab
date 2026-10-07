# AWS FedRAMP 20x Security Lab

A hands-on cloud security engineering and compliance portfolio project combining:

- AWS
- Terraform Infrastructure as Code (IaC)
- OPA/Rego Policy as Code (PaC)
- Git and GitHub
- CI/CD automation
- Continuous security validation
- Machine-readable security evidence
- Cross-framework security control traceability

## Primary Framework Alignment

The project primarily demonstrates alignment to:

- NIST SP 800-53
- FedRAMP, with the Moderate baseline as the primary traditional baseline
- FedRAMP 20x and applicable Key Security Indicators (KSIs)

## Secondary Cross-Framework Traceability

Where natural overlap exists, the same technical implementations and evidence
will also be traced to:

- NIST SP 800-171
- CMMC Level 2
- DoD Risk Management Framework (RMF)

The goal is to demonstrate how a single technical security capability and its
evidence can support multiple security and compliance frameworks without
building separate environments for each framework.

## Development Environment

- IDE: Visual Studio Code
- Integrated shell: PowerShell
- Version control: Git
- Remote repository: GitHub
- GitHub authentication and repository management: GitHub CLI

Git operations will intentionally be practiced using both:

1. Git commands from the VS Code integrated PowerShell terminal
2. The equivalent VS Code Source Control and GitHub graphical interfaces

This approach develops proficiency with the underlying Git workflow while also
learning an efficient modern IDE-based development process.

## Project Workflow

The project is designed to demonstrate the following relationship:

AWS security capability  
→ Terraform implementation  
→ OPA/Rego policy validation  
→ CI/CD automated testing  
→ Security evidence  
→ NIST SP 800-53  
→ FedRAMP  
→ FedRAMP 20x KSI  
→ NIST SP 800-171 / CMMC Level 2  
→ DoD RMF relevance

> This is a personal training and portfolio project. It is not a production
> FedRAMP authorization, CMMC certification, or formal assessment package.