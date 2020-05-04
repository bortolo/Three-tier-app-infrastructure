resource "azurerm_public_ip" "example" {
  name                = "jumpPublicIp"
  location            = var.location
  resource_group_name = var.resource_group_name
  #domain_name_label = "my-private-managment-network"
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "jumphost_sec_rule" {
    name                = "jumphost_sec_rule"
    location            = var.location
    resource_group_name = var.resource_group_name
    security_rule {
        name                       = "mgmtaccess"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# NIC
resource "azurerm_network_interface" "jumphost_NIC" {
  name                = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "jumphost_NIC"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}
# INSTANCE
resource "azurerm_virtual_machine" "jumphost_server" {
  name                  = var.prefix
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.jumphost_NIC.id]
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id        = var.storage_image_reference_id
  }
  storage_os_disk {
    name              = "Disk_jumphost"
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
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/myadmin/.ssh/authorized_keys"
      key_data = file("/Users/andreabortolossi/.ssh/id_rsa.pub")
      }
    }
  tags = {
  environment = "management"
  }
}

# LINK TO SECURITY GROUP
resource "azurerm_network_interface_security_group_association" "NIC_to_SecRules" {
    network_interface_id      = azurerm_network_interface.jumphost_NIC.id
    network_security_group_id = azurerm_network_security_group.jumphost_sec_rule.id
}
