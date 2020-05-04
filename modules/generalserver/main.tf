resource "azurerm_public_ip" "example" {
  name                = "jumpPublicIp"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "main" {
    name                = "${var.prefix}-sec-group"
    location            = var.location
    resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "main" {
        count                      = length(var.inbound_rules)
        name                       = "rule-${count.index}"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = var.inbound_rules[count.index]
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        resource_group_name         = var.resource_group_name
        network_security_group_name = azurerm_network_security_group.main.name
}

# NIC
resource "azurerm_network_interface" "main" {
  for_each = var.server_list
  name                = "${each.value.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "${each.value.prefix}"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}
# INSTANCE
resource "azurerm_virtual_machine" "jumphost_server" {
  count                 = var.number_of_servers
  name                  = "${var.prefix}-${count.index}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.main[count.index].id]
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id        = var.storage_image_reference_id
  }
  storage_os_disk {
    name              = "disk-${var.prefix}-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.hostname
    admin_username = var.hostname
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.hostname}/.ssh/authorized_keys"
      key_data = file(var.ssh_key)
      }
    }
  tags = {
  environment = "management"
  }
}

# LINK TO SECURITY GROUP
resource "azurerm_network_interface_security_group_association" "NIC_to_SecRules" {
    count = var.number_of_servers
    network_interface_id      = azurerm_network_interface.main[count.index].id
    network_security_group_id = azurerm_network_security_group.main.id
}
