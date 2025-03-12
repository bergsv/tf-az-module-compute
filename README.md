# Azure Compute Module

This module creates Azure virtual machines with associated resources, including boot diagnostics and backup integration capabilities.

## Features

- Creates Windows or Linux VMs
- Configurable network settings
- Support for data disks with custom configurations
- Boot diagnostics with optional storage account
- System-assigned or user-assigned managed identities
- Integration with backup services
- Availability zone and availability set support

## Quick Start

```terraform
module "simple_vm" {
  source = "path/to/tf-az-module-compute"

  # Required parameters
  compute_resource_group_name = "rg-simple-example"
  compute_location            = "westeurope"
  compute_nic_name            = "nic-example"
  compute_subnet_id           = "/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/.../subnets/..."
  compute_vm_name             = "vm-example"
  
  # Authentication (choose one based on OS type)
  compute_os_type             = "windows"  # or "linux"
  compute_admin_username      = "adminuser"
  compute_admin_password      = "YourSecureP@ssw0rd!"  # For Windows VMs
  # compute_ssh_public_key    = "ssh-rsa AAAA..."      # For Linux VMs
}
```

## Usage with Boot Diagnostics and Backup

```terraform
module "vm_example" {
  source = "path/to/tf-az-module-compute"

  compute_create_resource_group    = true
  compute_resource_group_name      = "rg-compute-example"
  compute_location                 = "westeurope"
  
  compute_nic_name                 = "nic-example"
  compute_subnet_id                = azurerm_subnet.example.id
  compute_private_ip_allocation    = "Static"
  compute_private_ip_address       = "10.0.1.10"
  
  compute_vm_name                  = "vm-example"
  compute_vm_size                  = "Standard_B2as_v2"
  compute_os_type                  = "windows"
  compute_admin_username           = "adminuser"
  compute_admin_password           = var.admin_password
  
  # Boot diagnostics
  compute_boot_diagnostics_enabled = true
  
  # High availability
  compute_availability_zone        = "1"
  
  # Security and management
  compute_identity_type            = "SystemAssigned"
  
  # Backup integration with existing Recovery Services Vault
  compute_backup_enabled           = true
  compute_backup_policy_id         = "/subscriptions/.../resourceGroups/rg-backup/providers/Microsoft.RecoveryServices/vaults/rsv-central/backupPolicies/daily"
  
  compute_data_disks = [
    {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
      lun                  = 10
      caching              = "ReadOnly"
    }
  ]
  
  compute_tags = {
    environment = "production"
    backup      = "daily"
  }
}
```

## Common Configuration Examples

### 1. Linux VM with SSH Authentication

```terraform
module "linux_vm" {
  source = "path/to/tf-az-module-compute"
  
  compute_resource_group_name = "rg-linux-example"
  compute_location            = "eastus"
  compute_nic_name            = "nic-linux"
  compute_subnet_id           = azurerm_subnet.example.id
  compute_vm_name             = "vm-linux"
  
  # Linux specific settings
  compute_os_type             = "linux"
  compute_admin_username      = "adminuser"
  compute_ssh_public_key      = "ssh-rsa AAAA..."
  
  # Image settings for Ubuntu
  compute_image_publisher     = "Canonical"
  compute_image_offer         = "UbuntuServer"
  compute_image_sku           = "18.04-LTS"
}
```

### 2. Windows VM with Public IP

```terraform
module "windows_vm_public" {
  source = "path/to/tf-az-module-compute"
  
  compute_resource_group_name = "rg-windows-public"
  compute_location            = "westus2"
  compute_nic_name            = "nic-win-public"
  compute_subnet_id           = azurerm_subnet.example.id
  compute_vm_name             = "vm-win-public"
  
  # Windows specific settings
  compute_os_type             = "windows"
  compute_admin_username      = "adminuser"
  compute_admin_password      = var.secure_password
  
  # Public IP settings
  compute_public_ip_enabled   = true
  compute_public_ip_allocation = "Static"
  compute_public_ip_sku       = "Standard"
}
```

## Important Considerations for Backup Integration

1. **Recovery Services Vault**: The backup vault should be created separately and referenced via the `compute_backup_policy_id` parameter.
2. **Backup Policies**: Define backup policies in the Recovery Services Vault before referencing them in the compute module.
3. **Identity Requirements**: System-assigned identity (`compute_identity_type = "SystemAssigned"`) is recommended for backup operations.
4. **Cross-Resource Group Operations**: When the backup vault is in a different resource group, ensure proper permissions are in place.
5. **Technical Implementation**: The module parses the backup policy ID to determine the resource group and recovery vault name.

## Module Structure

```
tf-az-module-compute/
├── main.tf        - Main resources (VMs, NICs, etc.)
├── variables.tf   - Input variables
├── outputs.tf     - Output definitions
└── README.md      - Documentation (this file)
```

## Required Variables

| Name | Description | Type |
|------|-------------|------|
| `compute_resource_group_name` | Name of the resource group to create | `string` |
| `compute_location` | Azure region where resources will be created | `string` |
| `compute_subnet_id` | ID of the subnet to connect the VM to | `string` |
| `compute_vm_name` | Name of the virtual machine | `string` |
| `compute_nic_name` | Name of the network interface | `string` |

Plus authentication variables based on the OS type:
- For Windows: `compute_admin_username` and `compute_admin_password`
- For Linux: `compute_admin_username` and `compute_ssh_public_key`

## Security Recommendations

1. **System-Assigned Identity**: Enable system-assigned identity for VMs that need to access other Azure resources securely.
2. **Network Security Groups**: Consider associating NSGs with VM network interfaces or subnets.
3. **OS Updates**: Plan for OS patching and updates through Azure Automation or VM extensions.
4. **Disk Encryption**: Consider enabling Azure Disk Encryption for sensitive workloads.

## Common Errors and Solutions

| Error | Solution |
|-------|----------|
| "Resource group already exists" | Set `compute_create_resource_group = false` and provide the existing resource group name in `compute_existing_resource_group_name` |
| "Public IP not found" | Ensure `compute_public_ip_enabled = true` |
| "Authentication failed" | Check that you've provided the correct password for Windows or SSH key for Linux |
| "Backup policy not found" | Verify the backup policy ID is correct and accessible |

