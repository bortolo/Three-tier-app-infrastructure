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
  name              = "jumphost"
  hostname          = "myadmin"
  storage_image_reference_id = "/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/ansibleserverImage"
  quantity          = 1
  inbound_port      = ["22"]
  outbound_port     = []
  ssh_key           = "/Users/andreabortolossi/.ssh/id_rsa.pub"
  enable_public_ip  = true
  environment_tag   = "management"
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

module "generalserver" {
  source                     = "../modules/generalserver"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  prefix                     = local.name
  subnet_id                  = module.network.management_subnet_id
  hostname                   = local.hostname
  storage_image_reference_id = local.storage_image_reference_id
  number_of_servers          = local.quantity
  inbound_rules              = local.inbound_port
  outbound_rules             = local.outbound_port
  ssh_key                    = local.ssh_key
  enable_public_ip           = local.enable_public_ip
  environment_tag            = local.environment_tag
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

# https://ubuntu.com/tutorials/install-and-configure-apache#1-overview
# https://openclassrooms.com/en/courses/2504541-ultra-fast-applications-using-node-js/2504972-creating-your-first-app-with-node-js
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
  records             = [azurerm_lb.applb.private_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "private_DNS"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.example-private.name
  virtual_network_id    = module.network.main_virtual_network_id
}

# LOAD BALANCER INTERNAL================================================================
resource "azurerm_lb" "applb" {
  name                = "appserver_LB"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  frontend_ip_configuration {
    name                          = "privateIP_LB"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = module.network.production_subnet_id
  }
}

resource "azurerm_lb_backend_address_pool" "applb" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.applb.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_rule" "applb" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.applb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "privateIP_LB"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.applb.id
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

# https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-8-on-ubuntu-16-04
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
  backend_address_pool_id     = azurerm_lb_backend_address_pool.applb.id
  server_tag                  = "app"
}
