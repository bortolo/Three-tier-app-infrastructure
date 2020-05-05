/*
********************************************************************************
REQUIREMENT
1) storage_image_reference_id available on Azure

OUTPUT
1) Provisioning of "number_of_servers" with the same configurations in the same security group

BUGS
1) Some bugs when deleting NIC resources or Security group resource (see below). You need to run terraform destroy several times to accomplish the result.

Error: A resource with the ID "/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/test-generalserver-module/providers/Microsoft.Network/networkInterfaces/test_generalserver-NIC-1" already exists - to be managed via Terraform this resource needs to be imported into the State. Please see the resource documentation for "azurerm_network_interface" for more information.
  on ../../generalserver/main.tf line 51, in resource "azurerm_network_interface" "main_public":
  51: resource "azurerm_network_interface" "main_public" {

Error: Error waiting for update of Network Interface "test_generalserver-NIC-2" (Resource Group "test-generalserver-module"): Code="OperationNotAllowed" Message="Operation 'startTenantUpdate' is not allowed on VM 'test_generalserver-2' since the VM is marked for deletion. You can only retry the Delete operation (or wait for an ongoing one to complete)." Details=[]

Error: Error deleting Network Security Group "test_generalserver-sec-group" (Resource Group "test-generalserver-module"): network.SecurityGroupsClient#Delete: Failure sending request: StatusCode=400 -- Original Error: Code="NetworkSecurityGroupOldReferencesNotCleanedUp" Message="Network security group test_generalserver-sec-group cannot be deleted because old references for the following Nics: (\n/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/test-generalserver-module/providers/Microsoft.Network/networkSecurityGroups/test_generalserver-sec-group:/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/test-generalserver-module/providers/Microsoft.Network/networkInterfaces/test_generalserver-NIC-2) and Subnet: (\n/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/test-generalserver-module/providers/Microsoft.Network/networkSecurityGroups/test_generalserver-sec-group:) have not been released yet." Details=[]

TO DO
1) Create if for ssh_pub_key_path variable

********************************************************************************
*/

locals {
  rgn                        = "test-generalserver-module"
  region                     = "westeurope"
  storage_image_reference_id = "/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/ansibleserverImage"
  vlan                       = "10.0.0.0/16"
  subnet                     = "10.0.1.0/24"
  ssh_pub_key_path           = "/Users/andreabortolossi/.ssh/id_rsa.pub"
  number_of_servers          = 4

}

provider "azurerm" {
  version = "=2.5.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
        name = local.rgn
        location = local.region
}

resource "azurerm_virtual_network" "main" {
  name                = "test_vlan"
  address_space       = [local.vlan]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "main" {
  name                 = "test_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = local.subnet
}

module "test_generalserver" {
  source                     = "../../generalserver"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  prefix                     = "test_generalserver"
  subnet_id                  = azurerm_subnet.main.id
  hostname                   = "myadmin"
  storage_image_reference_id = local.storage_image_reference_id
  number_of_servers          = local.number_of_servers
  inbound_rules              = ["22"]
  outbound_rules             = []
  ssh_key                    = local.ssh_pub_key_path
  enable_public_ip           = true
  environment_tag            = "management"
}
