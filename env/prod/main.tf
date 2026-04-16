module "linux_ha" {
  source = "../../modules/linux_ha"

  resource_group_name = "rg-prod"
  location            = "eastus"
  environment         = "prod"
  vm_count            = 1
  admin_password      = var.admin_password
}