module "linux_ha" {
  source = "../../modules/linux_ha"

  resource_group_name = "rg-dev"
  location            = "eastus"
  environment         = "dev"
  vm_count            = 1
  admin_password      = var.admin_password
}