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

variable "subnet_id" {
  type        = string
  description = "Subnet ID for EC2 Instance"
  nullable    = false
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security Group IDs for EC2 Instance"
  nullable    = false
}

variable "instance_name" {
  type        = string
  description = "instance_name for EC2 Instance"
  nullable    = false
}

variable "project_name" {
  type        = string
  description = "Project Name for EC2 Instance"
  nullable    = false
}

variable "environment" {
  type        = string
  description = "Environment for EC2 Instance"
  nullable    = false
}