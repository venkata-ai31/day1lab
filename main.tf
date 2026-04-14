# -----------------------------
# Resource   Group2
# -----------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-day1-terraform"
  location = "centralindia"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-ha"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
