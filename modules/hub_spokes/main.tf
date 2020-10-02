
resource "azurerm_virtual_network" "hub" {
  name                = "${var.prefix}-hub"
  address_space       = [var.hub_address_space]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_virtual_network" "spokes" {
  for_each            = var.spoke_address_map
  name                = "${var.prefix}_spoke_${each.key}"
  address_space       = [each.value]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_virtual_network_peering" "peer-HubToSpokes" {
  for_each                  = var.spoke_address_map
  name                      = "peerHubTo${each.key}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spokes[each.key].id
}

resource "azurerm_virtual_network_peering" "peer-SpokesToHub" {
  for_each                  = var.spoke_address_map
  name                      = "peer${each.key}ToHub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.spokes[each.key].name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}
