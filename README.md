# Azure Compute Module

This module creates Windows or Linux virtual machines in Microsoft Azure

## Features

- Creates Windows or Linux VMs
- Configurable network settings
- Support for data disks with custom configurations
- Boot diagnostics with managed storage (default) or custom storage account
- System-assigned or user-assigned managed identities
- Availability zone and availability set support

## Examples

### Minimal Example

```terraform
module "minimal_vm" {
  source = "github.com/my-org/tf-az-module-compute"

  # Required parameters
  compute_resource_group_name = "rg-example"
  compute_location            = "westeurope"
  compute_nic_name            = "nic-example"
  compute_subnet_id           = azurerm_subnet.example.id
  compute_vm_name             = "vm-example"
  
  # OS Authentication (Windows example)
  compute_os_type             = "windows"
  compute_admin_username      = "adminuser"
  compute_admin_password      = "SecurePassword123!"
}
```

### Full Example

```terraform
module "full_featured_vm" {
  source = "github.com/my-org/tf-az-module-compute"
  
  # Resource Group Settings
  compute_create_resource_group    = true
  compute_resource_group_name      = "rg-full-example"
  compute_location                 = "eastus2"
  
  # Network Settings
  compute_nic_name                 = "nic-full-example"
  compute_subnet_id                = azurerm_subnet.example.id
  compute_private_ip_allocation    = "Static"
  compute_private_ip_address       = "10.0.1.10"
  
  # Public IP Settings
  compute_public_ip_enabled        = true
  compute_public_ip_allocation     = "Static"
  compute_public_ip_sku            = "Standard"
  
  # VM Settings
  compute_vm_name                  = "vm-full-example"
  compute_vm_size                  = "Standard_D2s_v3"
  compute_os_type                  = "linux"
  compute_admin_username           = "linuxadmin"
  compute_ssh_public_key           = file("~/.ssh/id_rsa.pub")
  
  # OS Disk Settings
  compute_os_disk_caching          = "ReadWrite"
  compute_os_disk_storage_account_type = "Premium_LRS"
  
  # Image Settings
  compute_image_publisher          = "Canonical"
  compute_image_offer              = "UbuntuServer"
  compute_image_sku                = "20.04-LTS"
  compute_image_version            = "latest"
  
  # Data Disks
  compute_data_disks = [
    {
      disk_size_gb         = 100
      storage_account_type = "Premium_LRS"
      lun                  = 10
      caching              = "ReadWrite"
    },
    {
      disk_size_gb         = 200
      storage_account_type = "StandardSSD_LRS"
      lun                  = 11
      caching              = "None"
    }
  ]
  
  # Boot Diagnostics
  # Using managed storage for boot diagnostics (default)

  compute_boot_diagnostics_enabled = true
  
  # Availability Settings
  compute_availability_zone        = "1"
  
  # Identity Management
  compute_identity_type            = "SystemAssigned"
  
  # Resource Tagging
  compute_tags = {
    environment = "production"
    department  = "IT"
    project     = "core-infrastructure"
    managed-by  = "terraform"
  }
}
```

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

## Boot Diagnostics Configuration

The module supports three boot diagnostics configurations:

1. **Managed Storage (Default)**: Set `compute_boot_diagnostics_enabled = true` and do not specify a storage account URI. Azure will automatically use a managed storage account.

2. **Custom Storage Account**: Set `compute_boot_diagnostics_enabled = true` and specify a storage account URI with `compute_boot_diagnostics_storage_account_uri`.

3. **Disabled**: Set `compute_boot_diagnostics_enabled = false` to disable boot diagnostics completely.

## Common Errors and Solutions

| Error | Solution |
|-------|----------|
| "Resource group already exists" | Set `compute_create_resource_group = false` and provide the existing resource group name in `compute_existing_resource_group_name` |
| "Public IP not found" | Ensure `compute_public_ip_enabled = true` |
| "Authentication failed" | Check that you've provided the correct password for Windows or SSH key for Linux |
| "Boot diagnostics storage account not found" | Either remove the `compute_boot_diagnostics_storage_account_uri` to use managed storage or ensure the storage account exists and is accessible |

