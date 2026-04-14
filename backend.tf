terraform {
  backend "azurerm" {
    resource_group_name  = "day2lab"
    storage_account_name = "tfbackendday2lab"
    container_name       = "statefiles"
    key                  = "dev.terraform.tfstate"
  }
}
