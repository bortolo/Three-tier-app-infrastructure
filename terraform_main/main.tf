# READY TO USE IMAGES ==========================================================

/*
appserverImage:     /subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/appserverImage
ansibleserverImage: /subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/ansibleserverImage
nodejsserverImage:  /subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/nodejsserverImage
webserverImage:     /subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/webserverImage
*/


# CONFIG =======================================================================

locals {
  rgn     = "example-three-tier-app"            # Resource Group Name
  region  = "westeurope"                        # Selected Azure location where run the example

  # JUMPHOST SERVER CONFIGURATIONS
  J_name              = "jumphost"
  J_hostname          = "myadmin"
  J_storage_image_reference_id = "/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/ansibleserverImage"
  J_quantity          = 1
  J_inbound_port      = ["22"]
  J_outbound_port     = []
  J_ssh_key           = "/Users/andreabortolossi/.ssh/id_rsa.pub"
  J_enable_public_ip  = true
  J_environment_tag   = "management"
  J_disable_password_authentication = true

  # WEB SERVER CONFIGURATIONS
  W_name              = "web"
  W_hostname          = "myadmin"
  W_storage_image_reference_id = "/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/nodejsserverImage"
  W_quantity          = 0
  W_inbound_port      = ["8081"]
  W_outbound_port     = []
  W_ssh_key           = "/Users/andreabortolossi/.ssh/id_rsa.pub"
  W_enable_public_ip  = false
  W_environment_tag   = "web"

  # APP SERVER CONFIGURATIONS
  A_name              = "app"
  A_hostname          = "myadmin"
  A_storage_image_reference_id = "/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/appserverImage"
  A_quantity          = 0
  A_inbound_port      = ["8080"]
  A_outbound_port     = []
  A_ssh_key           = "/Users/andreabortolossi/.ssh/id_rsa.pub"
  A_enable_public_ip  = false
  A_environment_tag   = "app"
}

# MAIN =========================================================================

provider "azurerm" {
  version = "=2.5.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
        name = local.rgn
        location = local.region
}

module network {
  source                  = "../modules/network"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  prefix                  = "mynetwork"
  address_space           = "10.0.0.0/16"
  management_vlan         = "10.0.3.0/24"
  production_vlan         = "10.0.1.0/24"
  test_vlan               = "10.0.2.0/24"
}

# MANAGEMENT ===================================================================

resource "azurerm_availability_set" "jumphost_HA" {
  name                = "jumphost_HA"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "generalserver" {
  source                          = "../modules/generalserver"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  prefix                          = local.J_name
  subnet_id                       = module.network.management_subnet_id
  hostname                        = local.J_hostname
  storage_image_reference_id      = local.J_storage_image_reference_id
  number_of_servers               = local.J_quantity
  inbound_rules                   = local.J_inbound_port
  outbound_rules                  = local.J_outbound_port
  ssh_key                         = local.J_ssh_key
  enable_public_ip                = local.J_enable_public_ip
  environment_tag                 = local.J_environment_tag
  disable_password_authentication = local.J_disable_password_authentication
  availability_set_id             = azurerm_availability_set.jumphost_HA.id
}

# LOAD BALANCER WEB ============================================================

module "web_lb" {
  source                  = "../modules/loadbalancer/web"
  prefix                  = "webLB"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  protocol                = "Tcp"
  frontend_port           = 80
  backend_port            = local.W_inbound_port[0]
}

# WEBSERVERS ===================================================================

resource "azurerm_availability_set" "webserver_HA" {
  name                = "webserver_HA"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "generalwebserver" {
  source                      = "../modules/generalserver"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  prefix                      = local.W_name
  subnet_id                   = module.network.production_subnet_id
  hostname                    = local.W_hostname
  storage_image_reference_id  = local.W_storage_image_reference_id
  number_of_servers           = local.W_quantity
  inbound_rules               = local.W_inbound_port
  outbound_rules              = local.W_outbound_port
  ssh_key                     = local.W_ssh_key
  enable_public_ip            = local.W_enable_public_ip
  environment_tag             = local.W_environment_tag
  enable_backend_address_pool = true
  backend_address_pool_id     = module.web_lb.backend_address_pool_id
  availability_set_id         = azurerm_availability_set.webserver_HA.id
}

# DNS PRIVATE ZONE =============================================================

resource "azurerm_private_dns_zone" "example-private" {
  name                = "mydomain.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_a_record" "example" {
  name                = "test"
  zone_name           = azurerm_private_dns_zone.example-private.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [module.app_lb.private_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "private_DNS"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.example-private.name
  virtual_network_id    = module.network.main_virtual_network_id
}

# LOAD BALANCER INTERNAL =======================================================

module "app_lb" {
  source                  = "../modules/loadbalancer/app"
  prefix                  = "appLB"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  protocol                = "Tcp"
  frontend_port           = local.A_inbound_port[0]
  backend_port            = local.A_inbound_port[0]
  subnet_id               = module.network.production_subnet_id
}

# APPSERVERS ===================================================================

resource "azurerm_availability_set" "appserver_HA" {
  name                = "appserver_HA"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "generalappserver" {
  source                      = "../modules/generalserver"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  prefix                      = local.A_name
  subnet_id                   = module.network.production_subnet_id
  hostname                    = local.A_hostname
  storage_image_reference_id  = local.A_storage_image_reference_id
  number_of_servers           = local.A_quantity
  inbound_rules               = local.A_inbound_port
  outbound_rules              = local.A_outbound_port
  ssh_key                     = local.A_ssh_key
  enable_public_ip            = local.A_enable_public_ip
  environment_tag             = local.A_environment_tag
  enable_backend_address_pool = true
  backend_address_pool_id     = module.app_lb.backend_address_pool_id
  availability_set_id         = azurerm_availability_set.appserver_HA.id
}
