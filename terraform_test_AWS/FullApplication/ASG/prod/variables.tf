variable "awsusername" {
  description = "(Required) Aws username"
}

################################################################################
# Variables to use AMI image
################################################################################
variable "AMI_name" {
  description = "(Required) The name of the AMI (creat_AMI must be set to true to create the AMI)"
  type        = string
}

################################################################################
# Variable to create the app infrastructure
################################################################################
variable "key_pair_name" {
  description = "(Required) The key pair name to log in EC2 instances"
}
