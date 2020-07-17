/*
appserverImage:     /subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/appserverImage
ansibleserverImage: /subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/ansibleserverImage
nodejsserverImage:  /subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/nodejsserverImage
webserverImage:     /subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/webserverImage
*/

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
  W_quantity          = 1
  W_inbound_port      = ["8081"]
  W_outbound_port     = []
  W_ssh_key           = "/Users/andreabortolossi/.ssh/id_rsa.pub"
  W_enable_public_ip  = false
  W_environment_tag   = "web"

  # APP SERVER CONFIGURATIONS
  A_name              = "app"
  A_hostname          = "myadmin"
  A_storage_image_reference_id = "/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/appserverImage"
  A_quantity          = 1
  A_inbound_port      = ["8080"]
  A_outbound_port     = []
  A_ssh_key           = "/Users/andreabortolossi/.ssh/id_rsa.pub"
  A_enable_public_ip  = false
  A_environment_tag   = "app"
}

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
  availability_set_id         = azurerm_availability_set.jumphost_HA.id
}

# LOAD BALANCER WEB ============================================================

module "web_lb" {
  source                  = "../modules/loadbalancer/web"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  protocol                = "Tcp"
  frontend_port           = 80
  backend_port            = 8081
}

# WEBSERVERS ===================================================================
/*
resource "azurerm_network_security_group" "webserver_sec_rules" {
    name                = "webserver_sec_rules"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    security_rule {
        name                       = "webaccess"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8081"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_availability_set" "webserver_HA" {
  name                = "webserver_HA"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "web1" {
  source                      = "../modules/server"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  prefix                      = "web1"
  storage_image_reference_id  = "/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/nodejsserverImage"
  subnet_id                   = module.network.production_subnet_id
  hostname                    = "web1"
  availability_set_id         = azurerm_availability_set.webserver_HA.id
  security_group_id           = azurerm_network_security_group.webserver_sec_rules.id
  backend_address_pool_id     = module.web_lb.backend_address_pool_id
  server_tag                  = "web"
}
*/

resource "azurerm_availability_set" "webserver_HA" {
  name                = "webserver_HA"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "generalwebserver" {
  source                     = "../modules/generalserver"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  prefix                     = local.W_name
  subnet_id                  = module.network.production_subnet_id
  hostname                   = local.W_hostname
  storage_image_reference_id = local.W_storage_image_reference_id
  number_of_servers          = local.W_quantity
  inbound_rules              = local.W_inbound_port
  outbound_rules             = local.W_outbound_port
  ssh_key                    = local.W_ssh_key
  enable_public_ip           = local.W_enable_public_ip
  environment_tag            = local.W_environment_tag
  enable_backend_address_pool = true
  backend_address_pool_id    = module.web_lb.backend_address_pool_id
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
  records             = [azurerm_lb.app_lb.private_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "private_DNS"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.example-private.name
  virtual_network_id    = module.network.main_virtual_network_id
}

# LOAD BALANCER INTERNAL================================================================
resource "azurerm_lb" "app_lb" {
  name                = "appserver_LB"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  frontend_ip_configuration {
    name                          = "privateIP_LB"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = module.network.production_subnet_id
  }
}

resource "azurerm_lb_backend_address_pool" "app_lb" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.app_lb.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_rule" "app_lb" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.app_lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "privateIP_LB"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.app_lb.id
}

# APPSERVERS ===================================================================

resource "azurerm_network_security_group" "appserver_sec_rules" {
    name                = "appserver_sec_rules"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    security_rule {
        name                       = "appaccess"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_availability_set" "appserver_HA" {
  name                = "appserver_HA"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "app1" {
  source                      = "../modules/server"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  prefix                      = "app1"
  storage_image_reference_id  = "/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/appserverImage"
  subnet_id                   = module.network.production_subnet_id
  hostname                    = "app1"
  availability_set_id         = azurerm_availability_set.appserver_HA.id
  security_group_id           = azurerm_network_security_group.appserver_sec_rules.id
  backend_address_pool_id     = azurerm_lb_backend_address_pool.app_lb.id
  server_tag                  = "app"
}

/*
module "generalappserver" {
  source                     = "../modules/generalserver"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  prefix                     = local.A_name
  subnet_id                  = module.network.production_subnet_id
  hostname                   = local.A_hostname
  storage_image_reference_id = local.A_storage_image_reference_id
  number_of_servers          = local.A_quantity
  inbound_rules              = local.A_inbound_port
  outbound_rules             = local.A_outbound_port
  ssh_key                    = local.A_ssh_key
  enable_public_ip           = local.A_enable_public_ip
  environment_tag            = local.A_environment_tag
  enable_backend_address_pool = true
  backend_address_pool_id    = module.app_lb.backend_address_pool_id
}*/
