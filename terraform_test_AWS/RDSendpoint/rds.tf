#####
# DB
# db_1 is in custom VPC in database subnet
# db_2 is in custom VPC in public subnet
# db_3 is in default VPC in public subnet
#####

module "db_1" {
  source                  = "../../modules_AWS/terraform-aws-rds-master/"
  identifier              = "demodb1"
  engine                  = "mysql"
  engine_version          = "8.0.20"
  instance_class          = "db.t2.micro"
  allocated_storage       = 5
  storage_encrypted       = false
  name                    = "demodb1"
  username                = jsondecode(data.aws_secretsmanager_secret_version.db-secret.secret_string)["username"]
  password                = jsondecode(data.aws_secretsmanager_secret_version.db-secret.secret_string)["password"]
  port                    = "3306"
  vpc_security_group_ids  = [module.aws_security_group_db_custom.this_security_group_id]
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  publicly_accessible     = false
  backup_retention_period = 0
  db_subnet_group_name    = module.vpc.database_subnet_group
  family                  = "mysql8.0"
  major_engine_version    = "8.0"

  tags = local.user_tag
}

module "db_2" {
  source                  = "../../modules_AWS/terraform-aws-rds-master/"
  identifier              = "demodb2"
  engine                  = "mysql"
  engine_version          = "8.0.20"
  instance_class          = "db.t2.micro"
  allocated_storage       = 5
  storage_encrypted       = false
  name                    = "demodb2"
  username                = jsondecode(data.aws_secretsmanager_secret_version.db-secret.secret_string)["username"]
  password                = jsondecode(data.aws_secretsmanager_secret_version.db-secret.secret_string)["password"]
  port                    = "3306"
  vpc_security_group_ids  = [module.aws_security_group_db_custom.this_security_group_id]
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  publicly_accessible     = false
  backup_retention_period = 0
  //db_subnet_group_name = module.vpc.database_subnet_group
  subnet_ids           = module.vpc.public_subnets
  family               = "mysql8.0"
  major_engine_version = "8.0"

  tags = local.user_tag
}

module "db_3" {
  source                  = "../../modules_AWS/terraform-aws-rds-master/"
  identifier              = "demodb3"
  engine                  = "mysql"
  engine_version          = "8.0.20"
  instance_class          = "db.t2.micro"
  allocated_storage       = 5
  storage_encrypted       = false
  name                    = "demodb3"
  username                = jsondecode(data.aws_secretsmanager_secret_version.db-secret.secret_string)["username"]
  password                = jsondecode(data.aws_secretsmanager_secret_version.db-secret.secret_string)["password"]
  port                    = "3306"
  vpc_security_group_ids  = [module.aws_security_group_db_default.this_security_group_id]
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  publicly_accessible     = false
  backup_retention_period = 0
  subnet_ids              = data.aws_subnet_ids.all.ids
  family                  = "mysql8.0"
  major_engine_version    = "8.0"

  tags = local.user_tag
}

module "aws_security_group_db_custom" {
  source      = "../../modules_AWS/terraform-aws-security-group-master"
  name        = "db_security_group_custom"
  description = "Security group for db mysql in custom VPC"
  vpc_id      = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "allow all inbound"
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


module "aws_security_group_db_default" {
  source      = "../../modules_AWS/terraform-aws-security-group-master"
  name        = "db_security_group_default"
  description = "Security group for db mysql in default VPC"
  vpc_id      = data.aws_vpc.default.id
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
