locals {
  region            = "eu-central-1"                # Selected location where run the example
  instance_name     = "tomcat_server_chiara"               # name of the single server
  ami               = "ami-09d992b9d8aa89dcf"       # ami type:
                                                    # apache server; "ami-07982b5f754eddb42"
                                                    # jekins server; "ami-09c64ab847a42a0e9"
                                                    # tomcat server; "ami-09d992b9d8aa89dcf"
  #tags
  owner       = "andrea"                       # team responsible for this provisioning
  deployedby  = "terraform"                   # could be useful know which resources are provide through terraform provisioning
}

provider "aws" {
  version = "~> 2.0"
  region = "eu-central-1"
}

# VLAN provisioning
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_instance" "server" {
  ami                           = local.ami
  instance_type                 = "t2.small"
  associate_public_ip_address   = true
  security_groups               = ["${aws_security_group.instance.name}"]
  key_name                      = "management_services"

  tags = {
    Name        = local.instance_name
    Owner       = local.owner
    Delployedby = local.deployedby
  }
}

resource "aws_security_group" "instance" {
  name    = "${local.instance_name}_security_group"
}
resource "aws_security_group_rule" "allow_inbound_to_instance_CUSTOM" {
  type              = "ingress"
  security_group_id = aws_security_group.instance.id
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "allow_inbound_to_instance_SSH" {
  type              = "ingress"
  security_group_id = aws_security_group.instance.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.instance.id
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]
}
