output "loadbalancer_public_ip" {
  value       = azurerm_public_ip.webIP.ip_address
  description = "The public IP for web LB"
}

output "backend_address_pool_id" {
  value       = azurerm_lb_backend_address_pool.weblb.id
  description = "The public IP for web LB"
}
