variable "aws_region" {
  description = "AWS region used for the Phase 2 security lab."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging."
  type        = string
  default     = "aws-fedramp-20x-security-lab"
}

variable "environment" {
  description = "Environment designation for lab resources."
  type        = string
  default     = "lab"
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the project VPC."
  type        = string
  default     = "10.30.0.0/16"
}

variable "private_subnet_a_cidr" {
  description = "CIDR block assigned to private subnet A."
  type        = string
  default     = "10.30.10.0/24"
}

variable "private_subnet_b_cidr" {
  description = "CIDR block assigned to private subnet B."
  type        = string
  default     = "10.30.20.0/24"
}
