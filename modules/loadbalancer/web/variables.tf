variable "location" {
  description = "(Required) The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group where the load balancer resources will be placed."
  default     = "azure_lb-rg"
}

variable "protocol" {
  description = "(Required) The type of protocol for the LB rule"
  default = "Tcp"
}

variable "frontend_port" {
  description = "(Required) The inboud port"
  default     = 80
}

variable "backend_port" {
  description = "(Required) The backend port"
  default = 8080
}
