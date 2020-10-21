
locals {
  rgn     = "test_generalserver"            # Resource Group Name
  region  = "westeurope"                        # Selected Azure location where run the example

  # SERVER CONFIGURATIONS
  name                            = "jumphost"
  hostname                        = "jumphost"
  storage_image_reference_id      = "/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/ansibleserverImage"
  quantity                        = 1
  inbound_port                    = ["22","9090","9100","3000"]
  outbound_port                   = []
  ssh_key                         = "/Users/andreabortolossi/.ssh/id_rsa.pub"
  enable_public_ip                = true
  environment_tag                 = "management"
  disable_password_authentication = true
  vm_size                         = "Standard_B1s"
}

provider "azurerm" {
  version = ">=2.7"
  features {}
}

resource "azurerm_resource_group" "rg" {
        name = local.rgn
        location = local.region
}

resource "azurerm_virtual_network" "main_vlan" {
  name                = "main_vlan"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "main_subnet" {
  name                 = "main_subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main_vlan.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_availability_set" "generalserver_HA" {
  name                = "generalserver_HA"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "generalserver" {
  source                          = "../../modules/generalserver"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  prefix                          = local.name
  subnet_id                       = azurerm_subnet.main_subnet.id
  hostname                        = local.hostname
  storage_image_reference_id      = local.storage_image_reference_id
  number_of_servers               = local.quantity
  inbound_rules                   = local.inbound_port
  outbound_rules                  = local.outbound_port
  ssh_key                         = local.ssh_key
  enable_public_ip                = local.enable_public_ip
  environment_tag                 = local.environment_tag
  disable_password_authentication = local.disable_password_authentication
  availability_set_id             = azurerm_availability_set.generalserver_HA.id
  vm_size                         = local.vm_size
  username                        = var.username
  password                        = var.password
  monitoring_tag                  = "no"
}
