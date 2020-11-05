provider "aws" {
  region = "eu-central-1"
}

locals {

  user_tag = {
    Owner = var.awsusername
    Test  = "DNS"
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source = "../../modules_AWS/terraform-aws-vpc-master"

  name = "complete-example"

  cidr = "10.0.0.0/16" # 10.0.0.0/8 is reserved for EC2-Classic

  azs = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  private_subnets = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
  private_subnet_tags = {
    subnet_type = "private"
  }

  public_subnets = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]
  public_subnet_tags = {
    subnet_type = "public"
  }

  database_subnets = ["10.0.192.0/21", "10.0.200.0/21", "10.0.208.0/21"]
  database_subnet_tags = {
    subnet_type = "database"
  }

  create_database_subnet_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_classiclink             = false
  enable_classiclink_dns_support = false

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  customer_gateways = {
    IP1 = {
      bgp_asn    = 65112
      ip_address = "1.2.3.4"
    },
    IP2 = {
      bgp_asn    = 65112
      ip_address = "5.6.7.8"
    }
  }

  enable_vpn_gateway = true

  enable_dhcp_options = true
  //dhcp_options_domain_name         = "service.consul"
  //dhcp_options_domain_name_servers = ["127.0.0.1", "10.10.0.2"]

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = [{}]
  default_security_group_egress  = [{}]

  tags = local.user_tag

  vpc_endpoint_tags = {
    Project  = "Secret"
    Endpoint = "true"
  }
}
