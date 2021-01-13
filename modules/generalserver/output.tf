output "id" {
  description = "List of IDs of instances"
  value       = azurerm_virtual_machine.main_public.*.id
}