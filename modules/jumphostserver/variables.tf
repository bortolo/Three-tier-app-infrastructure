variable "location" {
  description = "(Required) The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group where the load balancer resources will be placed."
  default     = "azure_lb-rg"
}

variable "prefix" {
  description = "(Required) Default prefix to use with your resource names."
  default     = "mywebserver"
}

variable "subnet_id" {
  description = "(Required) Subnet id to assign to webserver."
}

variable "hostname" {
  description = "(Required) Name of the host."
  default     = "host"
}

variable "storage_image_reference_id" {
  description = "(Required) Id of the reference image"
}
