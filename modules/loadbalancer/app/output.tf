output "backend_address_pool_id" {
  value       = azurerm_lb_backend_address_pool.privateLB.id
  description = "The address of the backend pool"
}

output "private_ip_address" {
  value       = azurerm_lb.privateLB.private_ip_address
  description = "The private IP address of the load balancer"
}
