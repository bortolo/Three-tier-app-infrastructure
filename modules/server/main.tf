# NIC
resource "azurerm_network_interface" "server_NIC" {
  name                = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "server_NIC"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}
# INSTANCE
resource "azurerm_virtual_machine" "server" {
  name                  = var.prefix
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.server_NIC.id]
  availability_set_id   = var.availability_set_id
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id        = var.storage_image_reference_id
  }

  storage_os_disk {
    name              = "Disk${var.hostname}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.hostname
    admin_username = "myadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
    }
    tags = {
    environment = var.server_tag
    }
}
# LINK TO SECURITY GROUP
resource "azurerm_network_interface_security_group_association" "NIC_to_SecRules" {
    network_interface_id      = azurerm_network_interface.server_NIC.id
    network_security_group_id = var.security_group_id
}
# LINK TO LB BACKEND POOL
resource "azurerm_network_interface_backend_address_pool_association" "example" {
  network_interface_id    = azurerm_network_interface.server_NIC.id
  ip_configuration_name   = "server_NIC"
  backend_address_pool_id = var.backend_address_pool_id
}
