module "linux_ha" {
  source = "../../modules/linux_ha"

  resource_group_name = "rg-prod"
  location            = "centralindia"
  environment         = "prod"
  vm_count            = 2
  admin_password      = var.admin_password
}