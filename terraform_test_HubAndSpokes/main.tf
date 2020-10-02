
# CONFIG =======================================================================

locals {
  rgn     = "test-hub-and-spokes"            # Resource Group Name
  region  = "westeurope"                        # Selected Azure location where run the example
}

# MAIN =========================================================================

provider "azurerm" {
  version = ">=2.7"
  features {}
}

resource "azurerm_resource_group" "rg" {
        name = local.rgn
        location = local.region
}

module hub_spokes {
  source                  = "../modules/hub_spokes"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  prefix                  = "test_topology"
  hub_address_space       = "10.0.0.0/24"
  spoke_address_map = {
    spoke22="10.0.2.0/24"
    spoke33="10.0.3.0/24"
  }
}
