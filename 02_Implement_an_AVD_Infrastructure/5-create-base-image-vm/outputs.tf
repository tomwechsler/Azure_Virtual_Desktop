output "public_ip_address" {
  value = data.azurerm_public_ip.base.ip_address
}