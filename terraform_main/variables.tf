variable "W_quantity" {
  description = "(Required) Number of images to be provisioned"
  default = 1
}

variable "W_vm_size" {
  description = "Size of the Azure VM"
  type = string
  default = "Standard_B1ls"
}

variable "A_quantity" {
  description = "(Required) Number of images to be provisioned"
  default = 1
}

variable "A_vm_size" {
  description = "Size of the Azure VM"
  type = string
  default = "Standard_B1ls"
}
