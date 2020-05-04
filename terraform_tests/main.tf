locals {
  rgn     = "test-modules"            # Resource Group Name
  region  = "westeurope"                        # Selected Azure location where run the example
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
  source                  = "../network"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  prefix                  = "mynetwork"
  address_space           = "10.0.0.0/16"
  management_vlan         = "10.0.2.0/24"
  production_vlan         = "10.0.1.0/24"
}

module "jumphost" {
  source                     = "../generalserver"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  prefix                     = "jumphost"
  storage_image_reference_id = "/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/ansibleserverImage"
  subnet_id                  = module.network.management_subnet_id
  hostname                   = "myadmin"
  number_of_servers          = 1
  inbound_rules              = ["22","8080"]
  ssh_key                    = "/Users/andreabortolossi/.ssh/id_rsa.pub"
  server_list                = [
    {
      prefix:                     "xxx",
      hostname:                   "xxx"
    }
  ]
  /*
  server_list                = [
    {
      prefix:                     "xxx",
      hostname:                   "xxx",
      admin_password:             "xxx",
      ssh_key:                    "xxx",
      inbound_rules:              [{protocol:"Tcp",port:"22"},{protocol:"Tcp",port:"8080"}],
      outbound_rules:             [{}],
      storage_image_reference_id: "xxxxxx",
      subnet_id:                  "xxxxxx",
      tags:                       {environment:"production",tier:"web"},
      public_ip:                  "yes"
    }
  ]
  */
}
