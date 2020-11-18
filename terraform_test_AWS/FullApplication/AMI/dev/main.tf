provider "aws" {
  region = "eu-central-1"
}

locals {
  user_tag = {
    Owner = var.awsusername
    Test  = "AMI"
    Environment = "dev"
  }
  security_group_tag_db = {
    scope = "db_server"
  }
  ec2_tag = {
    server_type = "fe_server"
  }
  security_group_tag_ec2 = {
    scope = "fe_server"
  }
  database_route_table_tags = {
    type = "RDS db"
  }
}

################################################################################
# Create AMI image of the app
################################################################################
resource "aws_ami_from_instance" "example" {
  count = var.create_AMI ? 1 : 0
  name               = var.AMI_name
  source_instance_id = module.ec2_FE.id[0]
}

################################################################################
# Data sources to create custom VPC and custom subnets (public and database)
################################################################################
module "vpc" {
  source = "../../../../modules_AWS/terraform-aws-vpc-master"
  name   = "customVPC"
  cidr   = "10.0.0.0/16"
  azs    = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  public_subnets = ["10.0.128.0/20"]
  public_subnet_tags = {
    subnet_type = "public"
  }
  database_subnets = ["10.0.176.0/21"]
  database_subnet_tags = {
    subnet_type = "database"
  }
  enable_dhcp_options      = true
  dhcp_options_domain_name = "eu-central-1.compute.internal"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.user_tag
}

################################################################################
# Get information about cross services
################################################################################
data "aws_secretsmanager_secret_version" "db-secret" {
  name = var.db_secret_name
}

################################################################################
# Route53
################################################################################
resource "aws_route53_zone" "private" {
  name = "private_host_zone"
  vpc {
    vpc_id = module.vpc.vpc_id
  }

  tags = local.user_tag
}

resource "aws_route53_record" "database" {
  zone_id = aws_route53_zone.private.zone_id
  name    = jsondecode(data.aws_secretsmanager_secret_version.db-secret.secret_string)["DATABASE_URL"]
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.db.this_db_instance_address}"]
}

##################################################################
# Network Load Balancer with Elastic IPs attached
##################################################################

module "nlb" {
  source = "../../../../modules_AWS/terraform-aws-alb-master"

  name = "complete-nlb"
  load_balancer_type = "network"
  vpc_id = module.vpc.vpc_id
  subnet_mapping = [{ allocation_id : aws_eip.lb[0].id, subnet_id : module.vpc.public_subnets[0] }]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    },
  ]

  target_groups = [
    {
      name_prefix      = "tu1-"
      backend_protocol = "TCP"
      backend_port     = 8080
      target_type      = "instance"

      tags = {
        tcp_udp = true
      }
    },
  ]

  tags = local.user_tag
}

resource "aws_lb_target_group_attachment" "test" {
  count            = length(module.ec2_FE.id)
  target_group_arn = module.nlb.target_group_arns[0]
  target_id        = module.ec2_FE.id[count.index]
}

resource "aws_eip" "lb" {
  count = 1
  vpc   = true

  tags = local.user_tag
}

################################################################################
# EC2
################################################################################
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

module "ec2_FE" {
  source                      = "../../../../modules_AWS/terraform-aws-ec2-instance-master"
  name                        = "fe_server"
  instance_count              = 2
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = var.key_pair_name
  associate_public_ip_address = true
  monitoring                  = false
  vpc_security_group_ids      = [module.aws_security_group_FE.this_security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  iam_instance_profile        = var.iam_role_name //it is highly dependent on terraform custom module

  tags = merge(local.user_tag, local.ec2_tag)
}

module "aws_security_group_FE" {
  source      = "../../../../modules_AWS/terraform-aws-security-group-master"
  name        = "FE_security_group"
  description = "Security group for front-end servers"
  vpc_id      = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "http port"
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

  tags = merge(local.user_tag, local.security_group_tag_ec2)
}

################################################################################
# DB
################################################################################
module "db" {
  source                  = "../../../../modules_AWS/terraform-aws-rds-master/"
  identifier              = "demodb"
  engine                  = "mysql"
  engine_version          = "8.0.20"
  instance_class          = "db.t2.micro"
  allocated_storage       = 5
  storage_encrypted       = false
  name                    = "demodb"
  username                = jsondecode(data.aws_secretsmanager_secret_version.db-secret.secret_string)["USERNAME"]
  password                = jsondecode(data.aws_secretsmanager_secret_version.db-secret.secret_string)["PASSWORD"]
  port                    = "3306"
  vpc_security_group_ids  = [module.aws_security_group_db.this_security_group_id]
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  publicly_accessible     = false
  backup_retention_period = 0
  subnet_ids              = module.vpc.database_subnets
  family                  = "mysql8.0"
  major_engine_version    = "8.0"

  tags = local.user_tag
}

module "aws_security_group_db" {
  source      = "../../../../modules_AWS/terraform-aws-security-group-master"
  name        = "db_security_group"
  description = "Security group for db mysql"
  vpc_id      = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "allo all inbound"
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

  tags = merge(local.user_tag, local.security_group_tag_db)
}
