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
  description = "(Required) Subnet id to assign to server."
}

variable "hostname" {
  description = "(Required) Name of the host."
  default     = "host"
}

variable "storage_image_reference_id" {
  description = "(Required) Id of the reference image"
}

variable "number_of_servers" {
  description = "(Required) Number of images to be provisioned"
  default = 1
}

variable "inbound_rules" {
  description = "(Required) Which port to open in inbound"
  default = ["22"]
}

variable "outbound_rules" {
  description = "(Required) Which port to open in outbound"
  default = []
}

variable "ssh_key" {
  description = "(Optional) id_rsa.pub for ssh remote connection"
  default = "./dummy"
}

variable "enable_public_ip" {
  description = "If set to true, enable public_ip"
  type = bool
}

variable "environment_tag" {
  description = "(Optional) Define what is the environment for these servers"
  default = "management"
}

variable "enable_backend_address_pool" {
  description = "If set to true, enable backend_address_pool_id variable usage"
  type = bool
  default = false
}

variable "backend_address_pool_id" {
  description = "(Optional) Add the group of instances in a loadbalancer pool"
  type = string
  default = "NotApplicable"
}

variable "disable_password_authentication" {
  description = "(Optional) If set to true, disable password authentication for linux server"
  type = bool
  default = false
}

variable "availability_set_id" {
  description = "Add the group of instances in a HA set"
  type = string
}
