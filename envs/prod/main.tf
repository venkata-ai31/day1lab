resource "azurerm_resource_group" "rg" {
  name     = "rg-prod-terraform"
  location = "centralindia"
}

module "network" {
  source = "../../modules/network"

  vnet_name       = "vnet-prod"
  subnet_name     = "subnet-prod"
  address_space   = ["10.10.0.0/16"]
  subnet_prefix   = ["10.10.1.0/24"]
  location        = azurerm_resource_group.rg.location
  rg_name         = azurerm_resource_group.rg.name
}

module "compute" {
  source = "../../modules/compute"

  vm_count       = 2
  prefix         = "prod"
  vm_size        = "Standard_D2s_v3"
  location       = azurerm_resource_group.rg.location
  rg_name        = azurerm_resource_group.rg.name
  subnet_id      = module.network.subnet_id

  admin_username = "azureuser"
  admin_password = var.admin_password
}

module "loadbalancer" {
  source   = "../../modules/loadbalancer"
  location = azurerm_resource_group.rg.location
  rg_name  = azurerm_resource_group.rg.name
}