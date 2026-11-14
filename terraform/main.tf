provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Purpose     = "FedRAMP-20x-Security-Lab"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_a_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-${var.environment}-private-a"
    Tier = "private"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_b_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-${var.environment}-private-b"
    Tier = "private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt"
    Tier = "private"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

# Default-deny workload security group.
# No ingress or egress is permitted by default. Required connectivity
# will be added explicitly as documented workload dependencies are introduced.
resource "aws_security_group" "private_workload" {
  name        = "${var.project_name}-${var.environment}-private-workload-sg"
  description = "Default-deny security group for private lab workloads"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-private-workload-sg"
  }
}

# Default-deny workload IAM identity.
# The role trusts only Amazon EC2 and begins with no identity-based
# permissions. AWS service access will be added only when a documented
# workload dependency requires it.
data "aws_iam_policy_document" "ec2_workload_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "private_workload" {
  name               = "${var.project_name}-${var.environment}-private-workload-role"
  description        = "Default-deny IAM role for private lab workloads"
  assume_role_policy = data.aws_iam_policy_document.ec2_workload_assume_role.json

  tags = {
    Name = "${var.project_name}-${var.environment}-private-workload-role"
  }
}

# Explicitly manage the workload role's authorized managed-policy set as empty.
# Any out-of-band managed policy attachment will be reconciled on a future apply.
resource "aws_iam_role_policy_attachments_exclusive" "private_workload" {
  role_name   = aws_iam_role.private_workload.name
  policy_arns = []
}

# Explicitly manage the workload role's authorized inline-policy set as empty.
# Any out-of-band inline policy will be reconciled on a future apply.
resource "aws_iam_role_policies_exclusive" "private_workload" {
  role_name    = aws_iam_role.private_workload.name
  policy_names = []
}

resource "aws_iam_instance_profile" "private_workload" {
  name = "${var.project_name}-${var.environment}-private-workload-profile"
  role = aws_iam_role.private_workload.name

  tags = {
    Name = "${var.project_name}-${var.environment}-private-workload-profile"
  }
}