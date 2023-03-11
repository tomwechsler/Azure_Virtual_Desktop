output "windows_vm_password" {
  description = "Password for the windows VM"
  sensitive   = true
  value       = var.os_flavor == "windows" && var.admin_password == null ? element(concat(random_password.passwd.*.result, [""]), 0) : null
}

output "windows_vm_public_ips" {
  description = "Public IP's map for the all windows Virtual Machines"
  value       = var.enable_public_ip_address == true && var.os_flavor == "windows" ? zipmap(azurerm_windows_virtual_machine.win_vm.*.name, azurerm_windows_virtual_machine.win_vm.*.public_ip_address) : null
}

output "windows_vm_private_ips" {
  description = "Public IP's map for the all windows Virtual Machines"
  value       = var.os_flavor == "windows" ? zipmap(azurerm_windows_virtual_machine.win_vm.*.name, azurerm_windows_virtual_machine.win_vm.*.private_ip_address) : null
}

output "windows_virtual_machine_ids" {
  description = "The resource id's of all Windows Virtual Machine."
  value       = var.os_flavor == "windows" ? element(concat(azurerm_windows_virtual_machine.win_vm.*.id, [""]), 0) : null
}

output "network_security_group_ids" {
  description = "List of Network security groups and ids"
  value       = azurerm_network_security_group.nsg.id
}

output "vm_availability_set_id" {
  description = "The resource ID of Virtual Machine availability set"
  value       = var.enable_vm_availability_set == true ? element(concat(azurerm_availability_set.aset.*.id, [""]), 0) : null
}

output "active_directory_domain" {
  description = "The name of the active directory domain"
  value       = var.active_directory_domain
}

output "active_directory_netbios_name" {
  description = "The name of the active directory netbios name"
  value       = var.active_directory_netbios_name
}
