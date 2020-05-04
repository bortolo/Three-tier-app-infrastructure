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

variable "number_of_servers" {
  description = "(Required) Number of images to be provisioned"
  default = 1
}

variable "inbound_rules" {
  description = "(Required) Which port to open in inbound"
  default = ["22"]
}

variable "ssh_key" {
  description = "(Optional) id_rsa.pub for ssh remote connection"
  default = ""
}

variable "server_list" {
  description = "Server rules"
  type = list(object({
       prefix                      = string
       hostname                    = string
     }))
}

/*
variable "server_list" {
  description = "Server rules"
  type = list(object({
       prefix                      = string
       hostname                    = string
       admin_password              = string
       ssh_key                     = string
       inbound_rules               = list(object({protocol=string,port=string}))
       outbound_rules              = list(object({protocol=string,port=string}))
       storage_image_reference_id  = string
       subnet_id                   = string
       tags                        = object({environment=string,tier=string})
       public_ip                   = string
     }))
}*/
