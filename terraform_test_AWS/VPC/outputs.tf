output "public_instance_ip" {
  description = "ip of the public instance"
  value       = module.ec2_public.public_ip
}
output "private_instance_ip" {
  description = "ip of the private instance"
  value       = module.ec2_private.public_ip
}
output "database_instance_ip" {
  description = "ip of the database instance"
  value       = module.ec2_database.public_ip
}

output "public_instance_private_ip" {
  description = "private ip of the public instance"
  value       = module.ec2_public.private_ip
}
output "private_instance_private_ip" {
  description = "private ip of the private instance"
  value       = module.ec2_private.private_ip
}
output "database_instance_private_ip" {
  description = "private ip of the database instance"
  value       = module.ec2_database.private_ip
}
