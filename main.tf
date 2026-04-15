# -----------------------------
# Resource   Group1
# -----------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-day1-terraform"
  location = "centralindia"
  tags = {
  env        = "dev"
  owner      = "terraform-lab"
  test       = "prod"
  }
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


resource "azurerm_network_security_group" "nsg" {
  name                = "linux-ha-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "nic" {
  count               = 2
  name                = "nic-linux-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_availability_set" "avset" {
  name                         = "avset-linux-ha"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = 2
  name                = "ubuntu-vm-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  availability_set_id = azurerm_availability_set.avset.id

  size                            = "Standard_D2s_v3"
  admin_username                  = "azureuser"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]

  custom_data = base64encode(<<EOF
#!/bin/bash
apt update -y
apt install apache2 -y

echo "<h1>High Availability Lab</h1>" > /var/www/html/index.html
echo "<h2>Served from VM ${count.index}</h2>" >> /var/www/html/index.html
echo "<p>Hostname: $(hostname)</p>" >> /var/www/html/index.html

systemctl enable apache2
systemctl start apache2
EOF
  )

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

output "vm_private_ips" {
  value = azurerm_network_interface.nic[*].private_ip_address
}
