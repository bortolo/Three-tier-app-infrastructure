
# PRIVATE LB ==================

resource "azurerm_lb" "privateLB" {
  name                = "${var.prefix}-privateLB"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "IP_LB"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnet_id
  }
}

resource "azurerm_lb_backend_address_pool" "privateLB" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.privateLB.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_rule" "privateLB" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.privateLB.id
  name                           = "LBRule"
  protocol                       = var.protocol
  frontend_port                  = var.frontend_port
  backend_port                   = var.backend_port
  frontend_ip_configuration_name = "IP_LB"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.privateLB.id
}
