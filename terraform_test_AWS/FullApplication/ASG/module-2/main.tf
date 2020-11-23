################################################################################
# Get information about cross services
################################################################################
// data "aws_secretsmanager_secret" "db-secret" {
//   name = var.db_secret_name
// }
//
// data "aws_secretsmanager_secret_version" "db-secret-version" {
//   secret_id = data.aws_secretsmanager_secret.db-secret.id
// }

################################################################################
# Data sources to create custom VPC and custom subnets (public and database)
################################################################################
module "vpc" {
  source = "../../../../modules_AWS/terraform-aws-vpc-master"
  name   = var.vpc_name
  cidr   = var.vpc_cidr
  azs    = var.vpc_azs
  public_subnets = var.vpc_public_subnets
  public_subnet_tags = {
    subnet_type = "public"
  }
  database_subnets = var.vpc_database_subnets
  database_subnet_tags = {
    subnet_type = "database"
  }
  enable_dhcp_options      = true
  dhcp_options_domain_name = "eu-central-1.compute.internal"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.vpc_tags
}

################################################################################
# Route53
################################################################################
// resource "aws_route53_zone" "private" {
//   name = "private_host_zone"
//   vpc {
//     vpc_id = module.vpc.vpc_id
//   }
//
//   tags = var.route53_tags
// }
//
// resource "aws_route53_record" "database" {
//   zone_id = aws_route53_zone.private.zone_id
//   name    = jsondecode(data.aws_secretsmanager_secret_version.db-secret-version.secret_string)["DATABASE_URL"]
//   type    = "CNAME"
//   ttl     = "300"
//   records = ["${module.db.this_db_instance_address}"]
// }

##################################################################
# Application Load Balancer
##################################################################
module "alb" {
  source = "../../../../modules_AWS/terraform-aws-alb-master"

  name                 = var.alb_name
  load_balancer_type   = "application"
  vpc_id               = module.vpc.vpc_id
  security_groups      = [module.aws_security_group_ALB.this_security_group_id]
  subnets              = module.vpc.public_subnets

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]
  target_groups = [
  {
    name_prefix          = "h1"
    backend_protocol     = "HTTP"
    backend_port         = 8080
    target_type          = "instance"
    deregistration_delay = 10
    health_check = {
      enabled             = true
      interval            = 30
      path                = "/"
      port                = "traffic-port"
      healthy_threshold   = 3
      unhealthy_threshold = 3
      timeout             = 6
      protocol            = "HTTP"
      matcher             = "200-399"
    }
    tags = {
      InstanceTargetGroupTag = "baz"
    }
  },
  ]

  tags = var.alb_tags
}

module "aws_security_group_ALB" {
  source      = "../../../../modules_AWS/terraform-aws-security-group-master"
  name        = "ALB_security_group"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]

  tags = var.alb_tags
}

// resource "aws_autoscaling_attachment" "asg_attachment_bar" {
//   autoscaling_group_name = module.asg_prod.this_autoscaling_group_id
//   alb_target_group_arn   = module.alb.this_lb_arn
// }

################################################################################
# EC2 wit ASG
################################################################################
module "asg_prod" {
  source = "../../../../modules_AWS/terraform-aws-autoscaling-master"

  name = "asg-prod"

  # Launch configuration
  #
  # launch_configuration = "my-existing-launch-configuration" # Use the existing launch configuration
  # create_lc = false # disables creation of launch configuration
  lc_name = "example-lc"

  image_id                     = var.ec2_ami_id
  instance_type                = var.ec2_instance_type
  security_groups              = [module.aws_security_group_FE.this_security_group_id]
  associate_public_ip_address  = var.ec2_public_ip
  key_name                     = var.ec2_key_pair_name
  recreate_asg_when_lc_changes = true
  target_group_arns            = [module.alb.this_lb_arn]

  user_data                    = var.ec2_user_data

  # Auto scaling group
  asg_name                  = "example-asg"
  vpc_zone_identifier       = module.vpc.public_subnets
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  // service_linked_role_arn   = aws_iam_service_linked_role.autoscaling.arn

}

################################################################################
# EC2
################################################################################
// module "ec2_FE" {
//   source                      = "../../../../modules_AWS/terraform-aws-ec2-instance-master"
//   name                        = var.ec2_name
//   instance_count              = var.ec2_number_of_instances
//   ami                         = var.ec2_ami_id
//   instance_type               = var.ec2_instance_type
//   key_name                    = var.ec2_key_pair_name
//   associate_public_ip_address = var.ec2_public_ip
//   monitoring                  = false
//   vpc_security_group_ids      = [module.aws_security_group_FE.this_security_group_id]
//   subnet_id                   = module.vpc.public_subnets[0]
//   // iam_instance_profile        = var.ec2_iam_role_name //it is highly dependent on terraform custom module
//   user_data                   = var.ec2_user_data
//
//   tags = var.ec2_tags
// }

module "aws_security_group_FE" {
  source      = "../../../../modules_AWS/terraform-aws-security-group-master"
  name        = "FE_security_group"
  description = "Security group for front-end servers"
  vpc_id      = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH port"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  ingress_with_source_security_group_id = [
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Service name"
      source_security_group_id = module.aws_security_group_ALB.this_security_group_id
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

  tags = var.ec2_tags
}

################################################################################
# DB
################################################################################
// module "db" {
//   source                  = "../../../../modules_AWS/terraform-aws-rds-master/"
//   identifier              = var.db_identifier
//   engine                  = "mysql"
//   engine_version          = "8.0.20"
//   instance_class          = var.db_instance_class
//   allocated_storage       = 5
//   storage_encrypted       = false
//   name                    = var.db_name
//   username                = jsondecode(data.aws_secretsmanager_secret_version.db-secret-version.secret_string)["USERNAME"]
//   password                = jsondecode(data.aws_secretsmanager_secret_version.db-secret-version.secret_string)["PASSWORD"]
//   port                    = "3306"
//   vpc_security_group_ids  = [module.aws_security_group_db.this_security_group_id]
//   maintenance_window      = "Mon:00:00-Mon:03:00"
//   backup_window           = "03:00-06:00"
//   publicly_accessible     = false
//   backup_retention_period = 0
//   subnet_ids              = module.vpc.database_subnets
//   family                  = "mysql8.0"
//   major_engine_version    = "8.0"
//
//   tags = var.db_tags
// }
//
// module "aws_security_group_db" {
//   source      = "../../../../modules_AWS/terraform-aws-security-group-master"
//   name        = "db_security_group"
//   description = "Security group for db mysql"
//   vpc_id      = module.vpc.vpc_id
//   ingress_with_cidr_blocks = [
//     {
//       from_port   = 0
//       to_port     = 0
//       protocol    = -1
//       description = "allo all inbound"
//       cidr_blocks = "0.0.0.0/0"
//     },
//   ]
//   egress_with_cidr_blocks = [
//     {
//       from_port   = 0
//       to_port     = 0
//       protocol    = -1
//       description = "allow all outbound"
//       cidr_blocks = "0.0.0.0/0"
//     },
//   ]
//
//   tags = var.db_tags
// }
