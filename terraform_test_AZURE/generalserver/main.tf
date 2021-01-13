
locals {
  rgn     = "test_generalserver"            # Resource Group Name

  # SERVER CONFIGURATIONS
  inbound_port                    = ["22"]
  outbound_port                   = []
  enable_public_ip                = true
  environment_tag                 = "management"
  disable_password_authentication = true

}

provider "azurerm" {
  version = ">=2.7"
  features {}
}

resource "azurerm_resource_group" "rg" {
        name = local.rgn
        location = var.region
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
  prefix                          = "generalserver"
  subnet_id                       = azurerm_subnet.main_subnet.id
  hostname                        = "generalserver"
  storage_image_reference_id      = var.storage_image_reference_id
  number_of_servers               = var.server_quantity
  inbound_rules                   = local.inbound_port
  outbound_rules                  = local.outbound_port
  ssh_key                         = var.ssh_key
  enable_public_ip                = local.enable_public_ip
  environment_tag                 = local.environment_tag
  disable_password_authentication = local.disable_password_authentication
  availability_set_id             = azurerm_availability_set.generalserver_HA.id
  vm_size                         = var.vm_size
  username                        = var.server_username
  password                        = var.server_password
  monitoring_tag                  = "no"
}

resource "azurerm_managed_disk" "example" {
  name                 = "acctestmd"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  managed_disk_id    = azurerm_managed_disk.example.id
  virtual_machine_id = module.generalserver.id[0]
  lun                = "10"
  caching            = "ReadWrite"
}