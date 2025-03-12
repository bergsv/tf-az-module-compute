# Resource Group - Creates a new resource group if specified
resource "azurerm_resource_group" "resource_group" {
  count    = var.compute_create_resource_group ? 1 : 0
  name     = var.compute_resource_group_name
  location = var.compute_location
  tags     = var.compute_tags
}

# Local values for resource group properties - determines whether to use new or existing RG
locals {
  resource_group_name = var.compute_create_resource_group ? azurerm_resource_group.resource_group[0].name : var.compute_existing_resource_group_name
  resource_group_location = var.compute_create_resource_group ? azurerm_resource_group.resource_group[0].location : var.compute_location
}

# Network Interface - Primary network interface for the VM
resource "azurerm_network_interface" "nic" {
  name                = var.compute_nic_name
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.compute_subnet_id
    private_ip_address_allocation = var.compute_private_ip_allocation
    private_ip_address            = var.compute_private_ip_allocation == "Static" ? var.compute_private_ip_address : null
    public_ip_address_id          = var.compute_public_ip_enabled ? azurerm_public_ip.public_ip[0].id : null
  }

  tags = var.compute_tags
}

# Public IP - Created only when enabled through variables
resource "azurerm_public_ip" "public_ip" {
  count               = var.compute_public_ip_enabled ? 1 : 0
  name                = "${var.compute_vm_name}-pip"
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
  allocation_method   = var.compute_public_ip_allocation
  sku                 = var.compute_public_ip_sku
  tags                = var.compute_tags
}

# Windows Virtual Machine - Created when OS type is set to "windows"
resource "azurerm_windows_virtual_machine" "vm" {
  count                 = var.compute_os_type == "windows" ? 1 : 0
  name                  = var.compute_vm_name
  location              = local.resource_group_location
  resource_group_name   = local.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.compute_vm_size
  computer_name         = var.compute_vm_name
  admin_username        = var.compute_admin_username
  admin_password        = var.compute_admin_password
  availability_set_id   = var.compute_availability_set_id != "" ? var.compute_availability_set_id : null
  zone                  = var.compute_availability_zone

  os_disk {
    caching              = var.compute_os_disk_caching
    storage_account_type = var.compute_os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.compute_image_publisher
    offer     = var.compute_image_offer
    sku       = var.compute_image_sku
    version   = var.compute_image_version
  }

  dynamic "boot_diagnostics" {
    for_each = var.compute_boot_diagnostics_enabled ? [1] : []
    content {
      storage_account_uri = var.compute_boot_diagnostics_storage_account_uri != "" ? var.compute_boot_diagnostics_storage_account_uri : null
    }
  }

  dynamic "identity" {
    for_each = var.compute_identity_type != "" ? [1] : []
    content {
      type         = var.compute_identity_type
      identity_ids = var.compute_identity_type == "UserAssigned" || var.compute_identity_type == "SystemAssigned, UserAssigned" ? values(var.compute_user_assigned_identities) : null
    }
  }

  tags = var.compute_tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags that might be managed outside of Terraform
      tags["backup"],
      # Ignore changes to boot diagnostics that might be updated by the backup service
      boot_diagnostics,
    ]
  }
}

# Linux Virtual Machine - Created when OS type is set to "linux"
resource "azurerm_linux_virtual_machine" "vm" {
  count                 = var.compute_os_type == "linux" ? 1 : 0
  name                  = var.compute_vm_name
  location              = local.resource_group_location
  resource_group_name   = local.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.compute_vm_size
  computer_name         = var.compute_vm_name
  admin_username        = var.compute_admin_username
  availability_set_id   = var.compute_availability_set_id != "" ? var.compute_availability_set_id : null
  zone                  = var.compute_availability_zone
  
  admin_ssh_key {
    username   = var.compute_admin_username
    public_key = var.compute_ssh_public_key
  }

  os_disk {
    caching              = var.compute_os_disk_caching
    storage_account_type = var.compute_os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.compute_image_publisher
    offer     = var.compute_image_offer
    sku       = var.compute_image_sku
    version   = var.compute_image_version
  }

  dynamic "boot_diagnostics" {
    for_each = var.compute_boot_diagnostics_enabled ? [1] : []
    content {
      storage_account_uri = var.compute_boot_diagnostics_storage_account_uri != "" ? var.compute_boot_diagnostics_storage_account_uri : null
    }
  }

  dynamic "identity" {
    for_each = var.compute_identity_type != "" ? [1] : []
    content {
      type         = var.compute_identity_type
      identity_ids = var.compute_identity_type == "UserAssigned" || var.compute_identity_type == "SystemAssigned, UserAssigned" ? values(var.compute_user_assigned_identities) : null
    }
  }

  tags = var.compute_tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags that might be managed outside of Terraform
      tags["backup"],
      # Ignore changes to boot diagnostics that might be updated by the backup service
      boot_diagnostics,
    ]
  }
}

# Data Disks - Creates additional managed disks as specified in the variables
resource "azurerm_managed_disk" "data_disks" {
  count                = length(var.compute_data_disks)
  name                 = "${var.compute_vm_name}-disk-${count.index + 1}"
  location             = local.resource_group_location
  resource_group_name  = local.resource_group_name
  storage_account_type = lookup(var.compute_data_disks[count.index], "storage_account_type", "StandardSSD_LRS")
  create_option        = lookup(var.compute_data_disks[count.index], "create_option", "Empty")
  disk_size_gb         = lookup(var.compute_data_disks[count.index], "disk_size_gb", 128)
  zone                 = var.compute_availability_zone
  tags                 = var.compute_tags
}

# Data Disk Attachments - Attaches the data disks to the VM
resource "azurerm_virtual_machine_data_disk_attachment" "disk_attachments" {
  count              = length(var.compute_data_disks)
  managed_disk_id    = azurerm_managed_disk.data_disks[count.index].id
  virtual_machine_id = var.compute_os_type == "windows" ? azurerm_windows_virtual_machine.vm[0].id : azurerm_linux_virtual_machine.vm[0].id
  lun                = lookup(var.compute_data_disks[count.index], "lun", 10 + count.index)
  caching            = lookup(var.compute_data_disks[count.index], "caching", "None")
}

# VM Backup - Registers the VM with a backup policy when enabled
resource "azurerm_backup_protected_vm" "vm_backup" {
  count               = var.compute_backup_enabled && var.compute_backup_policy_id != "" ? 1 : 0
  resource_group_name = element(split("/", var.compute_backup_policy_id), 4)
  recovery_vault_name = element(split("/", var.compute_backup_policy_id), 8)
  source_vm_id        = var.compute_os_type == "windows" ? azurerm_windows_virtual_machine.vm[0].id : azurerm_linux_virtual_machine.vm[0].id
  backup_policy_id    = var.compute_backup_policy_id

  depends_on = [
    azurerm_windows_virtual_machine.vm,
    azurerm_linux_virtual_machine.vm
  ]
}
