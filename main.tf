# -----------------------------
# Resource  Group
# -----------------------------
resource "azurerm_resource_group" "rg" {
  name     = "day1rg"
  location = "centralindia"
}
