output "main_virtual_network_id" {
  value       = azurerm_virtual_network.main.id
  description = "The id of the main virtual network"
}

output "management_subnet_id" {
  value       = azurerm_subnet.management.id
  description = "The subnet id for the management services"
}

output "production_subnet_id" {
  value       = azurerm_subnet.production.id
  description = "The subnet id for the production services"
}

output "test_subnet_id" {
  value       = azurerm_subnet.test.id
  description = "The subnet id for the test services"
}
