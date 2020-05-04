output "server_private_ip" {
  value       = azurerm_network_interface.server_NIC.private_ip_address
  description = "The private IP for the web server"
}
