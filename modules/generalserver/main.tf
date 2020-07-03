# IP ===========================================================================

resource "azurerm_public_ip" "main" {
  count               = var.number_of_servers*(var.enable_public_ip ? 1 : 0)
  name                = "${var.prefix}-IP-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

# SECURITY RULES ===============================================================

resource "azurerm_network_security_group" "main" {
    name                = "${var.prefix}-sec-group"
    location            = var.location
    resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "main_inbound" {
        count                      = length(var.inbound_rules)*(var.number_of_servers>0 ? 1 : 0)
        name                       = "rule-inbound-${count.index}"
        priority                   = 1001+count.index
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

resource "azurerm_network_security_rule" "main_outbound" {
        count                      = length(var.outbound_rules)*(var.number_of_servers>0 ? 1 : 0)
        name                       = "rule-outbound-${count.index}"
        priority                   = 1001+count.index
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = var.outbound_rules[count.index]
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        resource_group_name         = var.resource_group_name
        network_security_group_name = azurerm_network_security_group.main.name
}

# NIC ==========================================================================

resource "azurerm_network_interface" "main_public" {
  count               = var.number_of_servers*(var.enable_public_ip ? 1 : 0)
  name                = "${var.prefix}-NIC-public-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "${var.prefix}-IPconf-${count.index}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main[count.index].id
  }
}

resource "azurerm_network_interface" "main_private" {
  count               = var.number_of_servers*(var.enable_public_ip ? 0 : 1)
  name                = "${var.prefix}-NIC-private-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "${var.prefix}-IPconf-${count.index}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# INSTANCE =====================================================================

resource "azurerm_virtual_machine" "main_public" {
  count                 = var.number_of_servers*(var.enable_public_ip ? 1 : 0)
  name                  = "${var.prefix}-public-${count.index}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.main_public[count.index].id]
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
  environment = var.environment_tag
  }
}

resource "azurerm_virtual_machine" "main_private" {
  count                 = var.number_of_servers*(var.enable_public_ip ? 0 : 1)
  name                  = "${var.prefix}-private-${count.index}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.main_private[count.index].id]
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
  environment = var.environment_tag
  }
}

# LINK INSTANCE TO SECURITY GROUP
resource "azurerm_network_interface_security_group_association" "main_public" {
    count = var.number_of_servers*(var.enable_public_ip ? 1 : 0)
    network_interface_id      = azurerm_network_interface.main_public[count.index].id
    network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_network_interface_security_group_association" "main_private" {
    count = var.number_of_servers*(var.enable_public_ip ? 0 : 1)
    network_interface_id      = azurerm_network_interface.main_private[count.index].id
    network_security_group_id = azurerm_network_security_group.main.id
}
