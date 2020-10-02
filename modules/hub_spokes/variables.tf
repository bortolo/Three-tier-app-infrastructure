variable "location" {
  description = "(Required) The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  default = "westeurope"
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group where the load balancer resources will be placed."
  default     = "test_HubandSpokes"
}

variable "prefix" {
  description = "(Required) Default prefix to use with your resource names."
  default     = "test_HubandSpokes"
}

variable "hub_address_space" {
  description = "(Required) Hub address space."
  default     = "10.0.0.0/24"
}

variable "spoke_address_space" {
  description = "(Required) List of all the spokes and their address spaces"
  default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "spoke_address_map" {
  type = map
  description = "(Required) List of all the spokes and their address spaces"
  default = {
    spoke1="10.0.1.0/24"
    spoke2="10.0.2.0/24"
  }
}
