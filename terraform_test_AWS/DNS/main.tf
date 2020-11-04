provider "aws" {
  region = "eu-central-1"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source = "../../modules_AWS/terraform-aws-vpc-master"
  name   = "complete-example"
  cidr   = "10.0.0.0/16"
  azs    = ["eu-central-1a"]

  private_subnets = ["10.0.0.0/19"]
  private_subnet_tags = {
    subnet_type = "private"
  }

  public_subnets = ["10.0.128.0/20"]
  public_subnet_tags = {
    subnet_type = "public"
  }

  //enable_dns_hostnames = true
  //enable_dns_support   = true

  enable_dhcp_options = true
  //dhcp_options_domain_name         = "awstestdomain.cf"
  //dhcp_options_domain_name_servers = ["127.0.0.1"]

  tags = {
    Owner       = "user"
    Environment = "staging"
    Name        = "complete"
  }
}

#*****************
#** DNS SERVER ***
#*****************

# Create a new instance of the latest Ubuntu 20.04 on an t2.micro node

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "this" {
  key_name   = "andreaskey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCVPI+y9VK/2KhV0kNH1boKE3xTkVIo57fWX1qf8+AR4uu+IIr1sM4LLWcbhTR4WY8okfzv9LoCl/LWg30ODsbLuYX2heamZOuSg5CyFSJj6i2RgS2M2wppKLo13+tEqUm4c4E6dnVk2YHeDs7A5asL1IUGnqvcpey2+ZMTgCEa6nfqxitSl3wWSuMZpNUTXtnQh/3Yp1dMlHjdUuiUCHEKIPyHdz2mF/i6yEf4RPLFWVKpX+o1TpfnoVlFipiobcqiZ0SOOgJsbqWGrykrdnYbvOYtKBpNF3OSTZdBaxRHtH907ykre+9gqTPnQFqq3hncUNQuQvpiv9SlZyuCVmr5 andreabortolossi@Andreas-MBP.lan"
}

resource "aws_eip" "lb" {
  instance = module.ec2_DNS.id[0]
  vpc      = true
}

module "ec2_DNS" {
  source                 = "../../modules_AWS/terraform-aws-ec2-instance-master"
  name                   = "dns_server"
  instance_count         = 1
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.this.key_name
  monitoring             = false
  vpc_security_group_ids = [module.aws_security_group_DNS.this_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "aws_security_group_DNS" {
  source      = "../../modules_AWS/terraform-aws-security-group-master"
  name        = "DNS_security_group"
  description = "Security group for DNS servers"
  vpc_id      = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 53
      to_port     = 53
      protocol    = "tcp"
      description = "DNS port"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      description = "DNS port"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH port"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "allow all outbound"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
