# We are going to create an Azure VM and place it in the poolSubnet
locals {
  base_name = "${var.prefix}-W10-MS"
}

# Create an Azure Resource Group
resource "azurerm_resource_group" "base" {
  name     = local.base_name
  location = var.location
}

# Create an Azure Virtual Network with one subnet
resource "azurerm_virtual_network" "base" {
  name                = local.base_name
  location            = azurerm_resource_group.base.location
  resource_group_name = azurerm_resource_group.base.name

  address_space = ["10.0.0.0/24"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.0.0/24"
  }

}

data "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.base.name
  virtual_network_name = azurerm_virtual_network.base.name
}

# Create a NIC for the Azure VM
resource "azurerm_network_interface" "base" {
  resource_group_name = azurerm_resource_group.base.name
  location            = azurerm_resource_group.base.location
  name                = local.base_name
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.base.id
    subnet_id                     = data.azurerm_subnet.subnet1.id
  }
}
# Create a public IP address for the Azure VM
resource "azurerm_public_ip" "base" {
  resource_group_name = azurerm_resource_group.base.name
  location            = azurerm_resource_group.base.location
  name                = local.base_name
  allocation_method   = "Dynamic"
}

# Create an NSG allowing 3389 from anywhere
resource "azurerm_network_security_group" "base" {
  resource_group_name = azurerm_resource_group.base.name
  location            = azurerm_resource_group.base.location
  name                = "allow_3389"
  security_rule {
    name                       = "allow_3389"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 100
    direction                  = "Inbound"
  }
}

# Assign the NSG to the NIC
resource "azurerm_network_interface_security_group_association" "base" {
  network_interface_id      = azurerm_network_interface.base.id
  network_security_group_id = azurerm_network_security_group.base.id
}

# Create an Azure VM
resource "azurerm_windows_virtual_machine" "base" {
  resource_group_name = azurerm_resource_group.base.name
  location            = azurerm_resource_group.base.location
  name                = local.base_name
  admin_username      = var.vmadmin_username
  admin_password      = var.vmadmin_password

  network_interface_ids = [azurerm_network_interface.base.id]
  size                  = "Standard_D2s_v3"
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-21h2-avd"
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  license_type = "Windows_Client"

}

# Get the public IP address of the Azure VM from a data source
data "azurerm_public_ip" "base" {
  name                = azurerm_public_ip.base.name
  resource_group_name = azurerm_public_ip.base.resource_group_name

  depends_on = [
    azurerm_network_interface.base
  ]
}