variable "location" {
  description = "(Required) The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  default = "westeurope"
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group where the load balancer resources will be placed."
  default     = "myexperiment"
}

variable "prefix" {
  description = "(Required) Default prefix to use with your resource names."
  default     = "mynetwork"
}

variable "management_vlan" {
  description = "(Required) Address space for mgmt purposes."
  default     = "10.0.3.0/24"
}

variable "production_vlan" {
  description = "(Required) Address space for production purposes."
  default     = "10.0.1.0/24"
}

variable "test_vlan" {
  description = "(Required) Address space for production purposes."
  default     = "10.0.2.0/24"
}

variable "address_space" {
  description = "(Required) Main address space."
  default     = "10.0.0.0/16"
}
