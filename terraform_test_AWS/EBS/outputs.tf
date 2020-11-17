output "ec2_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = module.ec2_public.public_ip
}
