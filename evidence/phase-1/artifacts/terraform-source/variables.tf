variable "project_name" {
  type        = string
  description = "Project Name"
  default     = "phase1-capstone"
}

variable "environment" {
  type        = string
  description = "Environment: Development/Stage/Production"
  default     = "dev"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR Address"
  default     = "10.20.0.0/16"
}

variable "subnet_cidr" {
  type        = string
  description = "Subnet CIDR Address"
  default     = "10.20.1.0/24"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 Instance"
  nullable    = false
}

variable "instance_type" {
  type        = string
  description = "Instance Type for EC2 Instance"
  nullable    = false
}

variable "instance_name" {
  type        = string
  description = "Instance Name for EC2 Instance"
  nullable    = false
}
