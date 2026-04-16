variable "resource_group_name" {}
variable "location" {}
variable "environment" {}

variable "vm_count" {
  default = 2
}

variable "admin_password" {
  type      = string
  sensitive = true
}