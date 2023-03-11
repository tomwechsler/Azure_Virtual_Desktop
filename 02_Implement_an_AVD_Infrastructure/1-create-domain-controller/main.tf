provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "vnet_hub" {
  name     = "vnet-hub-${var.azure_region}"
  location = var.azure_region
}

resource "azurerm_virtual_network" "vnet_hub" {
  name                = "vnet-hub-${var.azure_region}"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.vnet_hub.name

  address_space = [var.vnet_hub_address_space]
  dns_servers   = [var.dc_private_ip_address]

}

resource "azurerm_subnet" "subnets" {
  for_each             = var.vnet_hub_subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.vnet_hub.name
  virtual_network_name = azurerm_virtual_network.vnet_hub.name
  address_prefixes     = [each.value]
}

module "azure_dc" {
  source = "./azure_dc"

  resource_group_name  = azurerm_resource_group.vnet_hub.name
  location             = azurerm_resource_group.vnet_hub.location
  virtual_network_name = azurerm_virtual_network.vnet_hub.name
  subnet_name          = "adSubnet"

  virtual_machine_name               = "dc-${var.azure_region}"
  windows_distribution_name          = "windows2022dc"
  os_flavor                          = "windows"
  virtual_machine_size               = var.dc_virtual_machine_size
  admin_username                     = var.dc_admin_username
  private_ip_address_allocation_type = "Static"
  private_ip_address                 = [var.dc_private_ip_address]
  enable_public_ip_address           = true

  # Active Directory domain and netbios details
  # Intended for test/demo purposes
  # For production use of this module, fortify the security by adding correct nsg rules
  active_directory_domain       = var.dc_ad_domain_name
  active_directory_netbios_name = var.dc_ad_netbios_name

  nsg_inbound_rules = [
    {
      name                   = "rdp"
      destination_port_range = "3389"
      source_address_prefix  = "*"
    },

    {
      name                   = "dns"
      destination_port_range = "53"
      source_address_prefix  = "*"
    },
  ]

  depends_on = [
    azurerm_resource_group.vnet_hub,
    azurerm_subnet.subnets
  ]
}



