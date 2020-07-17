# IP ===========================================================================

resource "azurerm_public_ip" "main" {
  count               = var.number_of_servers*(var.enable_public_ip ? 1 : 0)
  name                = "${var.prefix}_IP_${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

# SECURITY RULES ===============================================================

resource "azurerm_network_security_group" "main" {
    name                = "${var.prefix}_sec_group"
    location            = var.location
    resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "main_inbound" {
        count                      = length(var.inbound_rules)*(var.number_of_servers>0 ? 1 : 0)
        name                       = "rule_inbound_${count.index}"
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
        name                       = "rule_outbound_${count.index}"
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
  name                = "${var.prefix}_NIC_public_${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "${var.prefix}_IPconf_${count.index}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main[count.index].id
  }
}

resource "azurerm_network_interface" "main_private" {
  count               = var.number_of_servers*(var.enable_public_ip ? 0 : 1)
  name                = "${var.prefix}_NIC_private_${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "${var.prefix}_IPconf_${count.index}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# INSTANCE =====================================================================

resource "azurerm_virtual_machine" "main_public" {
  count                 = var.number_of_servers*(var.enable_public_ip ? 1 : 0)
  name                  = "${var.prefix}_public_${count.index}"
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
    name              = "disk_${var.prefix}_${count.index}"
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
  name                  = "${var.prefix}_private_${count.index}"
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
    name              = "disk_${var.prefix}_${count.index}"
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
    disable_password_authentication = false
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

# LINK TO PRIVATE LB BACKEND POOL

# Probably the publicIP version of the code doesn't make sense
resource "azurerm_network_interface_backend_address_pool_association" "main_public" {
  count = var.number_of_servers*(var.enable_public_ip ? 1 : 0)*(var.enable_backend_address_pool ? 1 : 0)
  network_interface_id      = azurerm_network_interface.main_public[count.index].id
  ip_configuration_name     = "${var.prefix}_public_lbpool_${count.index}"
  backend_address_pool_id   = var.backend_address_pool_id
}

resource "azurerm_network_interface_backend_address_pool_association" "main_private" {
  count = var.number_of_servers*(var.enable_public_ip ? 0 : 1)*(var.enable_backend_address_pool ? 1 : 0)
  network_interface_id      = azurerm_network_interface.main_private[count.index].id
  ip_configuration_name     = "${var.prefix}_IPconf_${count.index}"
  backend_address_pool_id   = var.backend_address_pool_id
}
