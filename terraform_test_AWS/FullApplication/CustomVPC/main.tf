provider "aws" {
  region = "eu-central-1"
}

locals {
  user_tag = {
    Owner = var.awsusername
    Test  = "RDS endpoint"
  }
  security_group_tag_db     = { scope = "db_server" }
  ec2_tag                   = { server_type = "fe_server" }
  security_group_tag_ec2    = { scope = "fe_server" }
  database_route_table_tags = { type = "RDS db" }
}

################################################################################
# Data sources to create custom VPC and custom subnets (public and database)
################################################################################
module "vpc" {
  source = "../../modules_AWS/terraform-aws-vpc-master"
  name   = "RDSendpoint"
  cidr   = "10.0.0.0/16"
  azs    = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  public_subnets = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]
  public_subnet_tags = {
    subnet_type = "public"
  }

  database_subnets = ["10.0.176.0/21", "10.0.184.0/21", "10.0.192.0/21"]
  database_subnet_tags = {
    subnet_type = "database"
  }

  enable_dhcp_options      = true
  dhcp_options_domain_name = "eu-central-1.compute.internal"

  create_database_subnet_group = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.user_tag
}

################################################################################
# Data sources to get default VPC and subnets
################################################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

################################################################################
# Secret Manager
################################################################################
module "db-secrets" {
  source = "../../modules_AWS/terraform-aws-secrets-manager-master"
  secrets = [
    {
      name        = var.db_secret_name
      description = "db user and password"
      secret_key_value = {
        username = var.db_username
        password = var.db_password
        db_dns   = var.db_private_dns
      }
      recovery_window_in_days = 7
    },
  ]

  tags = local.user_tag
}

data "aws_secretsmanager_secret_version" "db-secret" {
  secret_id = module.db-secrets.secret_ids[0]
}

################################################################################
# Route53
################################################################################
resource "aws_route53_zone" "private" {
  name = "private_host_zone"
  vpc {
    vpc_id = module.vpc.vpc_id
    # Change route53 assignement
    //vpc_id = data.aws_vpc.default.id
  }

  tags = local.user_tag
}

resource "aws_route53_record" "database_1" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "${var.db_private_dns}_1"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.db_1.this_db_instance_address}"]
}


resource "aws_route53_record" "database_2" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "${var.db_private_dns}_2"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.db_2.this_db_instance_address}"]
}

resource "aws_route53_record" "database_3" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "${var.db_private_dns}_3"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.db_3.this_db_instance_address}"]
}

################################################################################
# IAM assumable role with custom policies
################################################################################
module "iam_assumable_role_custom" {
  source            = "../../modules_AWS/terraform-aws-iam-master/modules/iam-assumable-role"
  trusted_role_arns = []
  trusted_role_services = [
    "ec2.amazonaws.com"
  ]
  create_role             = true
  create_instance_profile = true
  role_name               = "custom"
  role_requires_mfa       = false
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
  ]

  tags = local.user_tag
}
