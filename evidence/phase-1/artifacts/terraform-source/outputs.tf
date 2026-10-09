output "instance_id" {
  description = "The ID of the EC2 Instance"
  value       = module.ec2.instance_id
}

output "private_ip" {
  description = "The Private IP Address of the EC2 Instance"
  value       = module.ec2.private_ip
}
