output "backend_address_pool_id" {
  value       = azurerm_lb_backend_address_pool.publicLB.id
  description = "The address of the backend pool"
}
