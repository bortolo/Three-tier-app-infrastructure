resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-mainvlan"
  address_space       = [var.address_space]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "management" {
  name                 = "${var.prefix}-management"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = var.management_vlan
}

resource "azurerm_subnet" "production" {
  name                 = "${var.prefix}-production"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = var.production_vlan
}

resource "azurerm_subnet" "test" {
  name                 = "${var.prefix}-test"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = var.test_vlan
}
