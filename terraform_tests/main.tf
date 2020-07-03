/*
appserverImage:     /subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/appserverImage
ansibleserverImage: /subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/ansibleserverImage
nodejsserverImage:  /subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/nodejsserverImage
webserverImage:     /subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/webserverImage
*/

locals {
  rgn               = "test-modules"                            # Resource Group Name
  region            = "westeurope"                              # Selected Azure location where run the example

  name              = "webserver"                               # Name of the server (identify the group of servers)
  hostname          = "myadmin"                                 # Hostname
  storage_image_reference_id = "/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/nodejsserverImage"
  quantity          = 2                                         # Number of servers
  inbound_port      = ["22","8080"]                             # Port to open inbound
  outbound_port     = ["80"]                             # Port to open outbound
  ssh_key           = "/Users/andreabortolossi/.ssh/id_rsa.pub" # Path to the SSH public key
  enable_public_ip  = true
  environment_tag   = "test"
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

module "generalserver" {
  source                     = "../modules/generalserver"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  prefix                     = local.name
  subnet_id                  = module.network.test_subnet_id
  hostname                   = local.hostname
  storage_image_reference_id = local.storage_image_reference_id
  number_of_servers          = local.quantity
  inbound_rules              = local.inbound_port
  outbound_rules             = local.outbound_port
  ssh_key                    = local.ssh_key
  enable_public_ip           = local.enable_public_ip
  environment_tag            = local.environment_tag
}
