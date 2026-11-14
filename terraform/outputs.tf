output "vpc_id" {
  description = "ID of the Phase 2 VPC."
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "IDs of the Phase 2 private subnets."
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

output "private_subnet_availability_zones" {
  description = "Availability Zones containing the Phase 2 private subnets."
  value = [
    aws_subnet.private_a.availability_zone,
    aws_subnet.private_b.availability_zone
  ]
}

output "private_route_table_id" {
  description = "ID of the route table associated with the private subnets."
  value       = aws_route_table.private.id
}

output "private_workload_security_group_id" {
  description = "ID of the default-deny security group for private workloads"
  value       = aws_security_group.private_workload.id
}

output "private_workload_iam_role_name" {
  description = "Name of the default-deny IAM role for private workloads"
  value       = aws_iam_role.private_workload.name
}

output "private_workload_instance_profile_name" {
  description = "Name of the IAM instance profile for private workloads"
  value       = aws_iam_instance_profile.private_workload.name
}