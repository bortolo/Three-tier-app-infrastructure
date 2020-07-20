# PUBLIC LB ==================

resource "azurerm_public_ip" "publicIP" {
  name                = "${var.prefix}-publicIP_LB"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_lb" "publicLB" {
  name                = "${var.prefix}-publicLB"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "IP_LB"
    public_ip_address_id          = azurerm_public_ip.publicIP.id
  }
}

resource "azurerm_lb_backend_address_pool" "publicLB" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.publicLB.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_rule" "publicLB" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.publicLB.id
  name                           = "LBRule"
  protocol                       = var.protocol
  frontend_port                  = var.frontend_port
  backend_port                   = var.backend_port
  frontend_ip_configuration_name = "IP_LB"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.publicLB.id
}
