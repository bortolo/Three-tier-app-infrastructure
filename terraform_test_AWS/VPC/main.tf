provider "aws" {
  region = "eu-central-1"
}

locals {
  user_tag = {
    Owner = var.awsusername
    Test  = "VPC"
  }

  ec2_tag_public = {server_type = "public"}
  ec2_tag_private = {server_type = "private"}
  ec2_tag_database = {server_type = "database"}

  security_group_tag_ec2 = {
                        scope = "security_server"
                        }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source = "../../modules_AWS/terraform-aws-vpc-master"

  name = "complete-example"

  cidr = "10.0.0.0/16"

  azs = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  private_subnets = ["10.0.0.0/21", "10.0.16.0/21", "10.0.32.0/21"]
  private_subnet_tags = {
    subnet_type = "private"
  }

  public_subnets = ["10.0.48.0/21", "10.0.64.0/21", "10.0.80.0/21"]
  public_subnet_tags = {
    subnet_type = "public"
  }

  database_subnets = ["10.0.96.0/21", "10.0.112.0/21", "10.0.128.0/21"]
  database_subnet_tags = {
    subnet_type = "database"
  }

  create_database_subnet_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_classiclink             = false
  enable_classiclink_dns_support = false

  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = false


  enable_vpn_gateway = false

  enable_dhcp_options = true
  //dhcp_options_domain_name         = "service.consul"
  //dhcp_options_domain_name_servers = ["127.0.0.1", "10.10.0.2"]


  tags = local.user_tag
}

##############
# Route53
##############
resource "aws_route53_zone" "private" {
  name = "private_host_zone"
  vpc {
    vpc_id = module.vpc.vpc_id
  }

  tags = local.user_tag
}

resource "aws_route53_record" "private" {
  zone_id = aws_route53_zone.private.zone_id
  name = "private.example.com"
  type = "A"
  ttl = "300"
  records = ["${module.ec2_private.private_ip[0]}"]
}

resource "aws_route53_record" "database" {
  zone_id = aws_route53_zone.private.zone_id
  name = "database.example.com"
  type = "A"
  ttl = "300"
  records = ["${module.ec2_database.private_ip[0]}"]
}

#######
# EC2
#######
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
  key_name   = "${local.user_tag.Owner}${local.user_tag.Test}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCVPI+y9VK/2KhV0kNH1boKE3xTkVIo57fWX1qf8+AR4uu+IIr1sM4LLWcbhTR4WY8okfzv9LoCl/LWg30ODsbLuYX2heamZOuSg5CyFSJj6i2RgS2M2wppKLo13+tEqUm4c4E6dnVk2YHeDs7A5asL1IUGnqvcpey2+ZMTgCEa6nfqxitSl3wWSuMZpNUTXtnQh/3Yp1dMlHjdUuiUCHEKIPyHdz2mF/i6yEf4RPLFWVKpX+o1TpfnoVlFipiobcqiZ0SOOgJsbqWGrykrdnYbvOYtKBpNF3OSTZdBaxRHtH907ykre+9gqTPnQFqq3hncUNQuQvpiv9SlZyuCVmr5 andreabortolossi@Andreas-MBP.lan"

  tags = local.user_tag
}

module "ec2_public" {
  source                 = "../../modules_AWS/terraform-aws-ec2-instance-master"
  name                   = "public_server"
  instance_count         = 1
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.this.key_name
  associate_public_ip_address = true //use this feature only for test/dev purposes
  monitoring             = false
  vpc_security_group_ids = [module.aws_security_group_server.this_security_group_id]
  subnet_id              = tolist(module.vpc.public_subnets)[0]

  tags = merge(local.user_tag,local.ec2_tag_public)
}

module "ec2_private" {
  source                 = "../../modules_AWS/terraform-aws-ec2-instance-master"
  name                   = "private_server"
  instance_count         = 1
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.this.key_name
  associate_public_ip_address = true //use this feature only for test/dev purposes
  monitoring             = false
  vpc_security_group_ids = [module.aws_security_group_server.this_security_group_id]
  subnet_id              = tolist(module.vpc.private_subnets)[0]

  tags = merge(local.user_tag,local.ec2_tag_private)
}

module "ec2_database" {
  source                 = "../../modules_AWS/terraform-aws-ec2-instance-master"
  name                   = "database_server"
  instance_count         = 1
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.this.key_name
  associate_public_ip_address = true //use this feature only for test/dev purposes
  monitoring             = false
  vpc_security_group_ids = [module.aws_security_group_server.this_security_group_id]
  subnet_id              = tolist(module.vpc.database_subnets)[0]

  tags = merge(local.user_tag,local.ec2_tag_database)
}

module "aws_security_group_server" {
  source      = "../../modules_AWS/terraform-aws-security-group-master"
  name        = "server_security_group"
  description = "Security group for servers"
  vpc_id      = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH port"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8
      to_port     = 0
      protocol    = "icmp"
      description = "ICMP"
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

  tags = merge(local.user_tag,local.security_group_tag_ec2)
}
