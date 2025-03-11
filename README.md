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

## Usage with Boot Diagnostics and Backup

```terraform
module "vm_example" {
  source = "./modules/azure-compute"

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

## Important Considerations for Backup Integration

1. **Recovery Services Vault**: The backup vault should be created separately and referenced in the backup configuration.
2. **Backup Policies**: Define backup policies in the Recovery Services Vault and reference them in your backup protected VM resources.
3. **Identity Requirements**: System-assigned identities may require proper RBAC roles to allow backup operations.
4. **Cross-Resource Group Operations**: When the backup vault is in a different resource group, ensure proper permissions are in place.
5. **Lifecycle Management**: Use the `depends_on` attribute when creating backup protected VM resources to ensure VM creation completes first.

## Security Recommendations

1. **System-Assigned Identity**: Enable system-assigned identity for VMs that need to access other Azure resources securely.
2. **Network Security Groups**: Consider associating NSGs with VM network interfaces or subnets.
3. **OS Updates**: Plan for OS patching and updates through Azure Automation or VM extensions.
4. **Disk Encryption**: Consider enabling Azure Disk Encryption for sensitive workloads.

## Monitoring and Management

1. **VM Extensions**: Consider adding diagnostic extensions such as Azure Monitor Agent.
2. **Log Analytics Workspace**: Connect VMs to a Log Analytics workspace for detailed monitoring.
3. **Custom Script Extensions**: For post-deployment configuration, consider using custom script extensions.

