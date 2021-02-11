variable "prefix" {
  description = "The prefix which should be used for all resources in this project"
}

variable "location" {
  description = "The Azure Region in which all resources in this project should be created."
}

variable "admin_username" {
  type = string
  description = "Administrator username for server"
}

variable "admin_password" {
  type = string
  description = "Administrator password for server"
}

variable "vm-count" {
  description = "Number of virtual machines"
}

variable "packer_image" {
  description = "The ID of the image created by packer"
  default = "/subscriptions/f302118d-9aa3-4a15-b777-e751773575ee/resourceGroups/packer-rg/providers/Microsoft.Compute/images/Prj1Ubuntu1804Image"
}
