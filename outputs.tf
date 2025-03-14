output "resource_group_name" {
  description = "The name of the resource group"
  value       = local.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = local.resource_group_location
}

output "vm_id" {
  description = "The ID of the virtual machine"
  value       = var.compute_os_type == "windows" ? (length(azurerm_windows_virtual_machine.vm) > 0 ? azurerm_windows_virtual_machine.vm[0].id : null) : (length(azurerm_linux_virtual_machine.vm) > 0 ? azurerm_linux_virtual_machine.vm[0].id : null)
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = var.compute_vm_name
}

output "nic_id" {
  description = "The ID of the network interface"
  value       = azurerm_network_interface.nic.id
}

output "private_ip_address" {
  description = "The private IP address of the virtual machine"
  value       = azurerm_network_interface.nic.private_ip_address
}

output "public_ip_address" {
  description = "The public IP address of the virtual machine"
  value       = var.compute_public_ip_enabled ? azurerm_public_ip.public_ip[0].ip_address : null
}

output "vm_principal_id" {
  description = "The Principal ID of the system-assigned identity of the VM (if enabled)"
  value       = var.compute_identity_type == "SystemAssigned" || var.compute_identity_type == "SystemAssigned, UserAssigned" ? (
    var.compute_os_type == "windows" ? 
    try(azurerm_windows_virtual_machine.vm[0].identity[0].principal_id, "") : 
    try(azurerm_linux_virtual_machine.vm[0].identity[0].principal_id, "")
  ) : ""
}

output "os_type" {
  description = "The type of OS of the VM (windows or linux)"
  value       = var.compute_os_type
}

output "resource_group_id" {
  description = "The ID of the resource group containing the VM"
  value       = var.compute_create_resource_group ? azurerm_resource_group.resource_group[0].id : null
}

output "computer_name" {
  description = "The computer name of the VM"
  value       = var.compute_vm_name
}

output "vm_zone" {
  description = "The availability zone of the VM (if assigned)"
  value       = var.compute_availability_zone
}