resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name        = var.instance_name
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}