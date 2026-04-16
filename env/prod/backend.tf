terraform {
  backend "azurerm" {
    resource_group_name  = "storageacrg"
    storage_account_name = "tfbackendday2lab"
    container_name       = "tfstate"
    key                  = "prod.tfstate"
  }
}