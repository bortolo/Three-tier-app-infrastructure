resource "azurerm_public_ip" "webIP" {
  name                = "public_app_IP"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_lb" "weblb" {
  name                = "webserver_LB"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "publicIP_LB"
    public_ip_address_id          = azurerm_public_ip.webIP.id
  }
}

resource "azurerm_lb_backend_address_pool" "weblb" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.weblb.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_rule" "example" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.weblb.id
  name                           = "LBRule"
  protocol                       = var.protocol
  frontend_port                  = var.frontend_port
  backend_port                   = var.backend_port
  frontend_ip_configuration_name = "publicIP_LB"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.weblb.id
}
