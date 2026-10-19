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
