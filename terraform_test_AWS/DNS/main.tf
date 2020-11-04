provider "aws" {
  region = "eu-central-1"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source = "../../modules_AWS/terraform-aws-vpc-master"

  name = "complete-example"

  cidr = "10.0.0.0/16" # 10.0.0.0/8 is reserved for EC2-Classic

  azs                 = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  private_subnets     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
  private_subnet_tags = {
    subnet_type       = "private"
  }

  public_subnets      = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]
  public_subnet_tags = {
    subnet_type       = "public"
  }

  database_subnets    = ["10.0.192.0/21", "10.0.200.0/21", "10.0.208.0/21"]
  database_subnet_tags = {
    subnet_type       = "database"
  }

  create_database_subnet_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_classiclink             = false
  enable_classiclink_dns_support = false

  enable_nat_gateway = false
  //single_nat_gateway = false
  //one_nat_gateway_per_az = true

  enable_dhcp_options              = true
  //dhcp_options_domain_name         = "service.consul"
  //dhcp_options_domain_name_servers = ["127.0.0.1", "10.10.0.2"]

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = [{}]
  default_security_group_egress  = [{}]

  tags = {
    Owner       = "user"
    Environment = "staging"
    Name        = "complete"
  }

  vpc_endpoint_tags = {
    Project  = "Secret"
    Endpoint = "true"
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
  key_name        = "andreaskey"
  public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCVPI+y9VK/2KhV0kNH1boKE3xTkVIo57fWX1qf8+AR4uu+IIr1sM4LLWcbhTR4WY8okfzv9LoCl/LWg30ODsbLuYX2heamZOuSg5CyFSJj6i2RgS2M2wppKLo13+tEqUm4c4E6dnVk2YHeDs7A5asL1IUGnqvcpey2+ZMTgCEa6nfqxitSl3wWSuMZpNUTXtnQh/3Yp1dMlHjdUuiUCHEKIPyHdz2mF/i6yEf4RPLFWVKpX+o1TpfnoVlFipiobcqiZ0SOOgJsbqWGrykrdnYbvOYtKBpNF3OSTZdBaxRHtH907ykre+9gqTPnQFqq3hncUNQuQvpiv9SlZyuCVmr5 andreabortolossi@Andreas-MBP.lan"
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
  source = "../../modules_AWS/terraform-aws-security-group-master"
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
