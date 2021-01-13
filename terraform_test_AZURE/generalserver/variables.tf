variable "region" {
  description = "Azure region to deploy the servers"
  type = string
}

variable "server_username" {
  description = "(Required) server username"
  type = string
}

variable "server_password" {
  description = "(Required) server password for the username"
  type = string
}

variable "storage_image_reference_id" {
  description = "id of the ready to use ARM image"
  type = string
}

variable "server_quantity" {
  description = "number of server to be deployed"
  type = number
  default = 1
}

variable "ssh_key" {
  description = "full path to the public key ssh file"
  type = string
} 

variable "vm_size" {
  description = "Size of the Azure VM"
  type = string
}