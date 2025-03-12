# Resource Group Variables
variable "compute_create_resource_group" {
  description = "Boolean flag to create a new resource group or use existing"
  type        = bool
  default     = true
}

variable "compute_resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
  validation {
    condition     = length(var.compute_resource_group_name) > 1 && length(var.compute_resource_group_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

variable "compute_existing_resource_group_name" {
  description = "Name of the existing resource group to use if not creating a new one"
  type        = string
  default     = ""
}

variable "compute_location" {
  description = "Azure region where resources will be created"
  type        = string
}

# Network Interface Variables
variable "compute_nic_name" {
  description = "Name of the network interface"
  type        = string
}

variable "compute_subnet_id" {
  description = "ID of the subnet to connect the VM to"
  type        = string
}

variable "compute_private_ip_allocation" {
  description = "IP allocation method for private IP (Static or Dynamic)"
  type        = string
  default     = "Dynamic"
}

variable "compute_private_ip_address" {
  description = "Static private IP address (only used if allocation is Static)"
  type        = string
  default     = ""
}

# Public IP Variables
variable "compute_public_ip_enabled" {
  description = "Boolean flag to add a public IP to the VM"
  type        = bool
  default     = false
}

variable "compute_public_ip_allocation" {
  description = "IP allocation method for public IP (Static or Dynamic)"
  type        = string
  default     = "Static"
}

variable "compute_public_ip_sku" {
  description = "SKU for the public IP (Basic or Standard)"
  type        = string
  default     = "Standard"
}

# VM Variables
variable "compute_vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "compute_vm_size" {
  description = "Size/SKU of the virtual machine (e.g., Standard_B2as_v2, Standard_D2s_v3)"
  type        = string
  default     = "Standard_B2as_v2"
}

variable "compute_os_type" {
  description = "OS type (windows or linux)"
  type        = string
  default     = "windows"
  validation {
    condition     = contains(["windows", "linux"], var.compute_os_type)
    error_message = "OS type must be either 'windows' or 'linux'."
  }
}

variable "compute_admin_username" {
  description = "Username for the VM admin"
  type        = string
  default     = "srvadmin"
}

variable "compute_admin_password" {
  description = "Password for the VM admin (for Windows VMs). Must be at least 12 characters with a mix of uppercase, lowercase, numbers, and special characters"
  type        = string
  default     = ""
  sensitive   = true
  validation {
    condition     = var.compute_admin_password == "" || length(var.compute_admin_password) >= 12
    error_message = "Admin password must be at least 12 characters when provided."
  }
}

variable "compute_ssh_public_key" {
  description = "SSH public key for the admin user (for Linux VMs)"
  type        = string
  default     = ""
}

# OS Disk Variables
variable "compute_os_disk_caching" {
  description = "Caching type for OS disk (None, ReadOnly, ReadWrite)"
  type        = string
  default     = "ReadWrite"
}

variable "compute_os_disk_storage_account_type" {
  description = "Storage account type for OS disk (StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS, Premium_ZRS)"
  type        = string
  default     = "StandardSSD_LRS"
  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "StandardSSD_ZRS", "Premium_ZRS"], var.compute_os_disk_storage_account_type)
    error_message = "OS disk storage type must be one of Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS, or Premium_ZRS."
  }
}

# Image Reference Variables
variable "compute_image_publisher" {
  description = "Publisher of the VM image"
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "compute_image_offer" {
  description = "Offer of the VM image"
  type        = string
  default     = "WindowsServer"
}

variable "compute_image_sku" {
  description = "SKU of the VM image"
  type        = string
  default     = "2022-Datacenter"
}

variable "compute_image_version" {
  description = "Version of the VM image"
  type        = string
  default     = "latest"
}

# Data Disks Variable
variable "compute_data_disks" {
  description = "List of data disks to attach to the VM (each containing storage_account_type, create_option, disk_size_gb, lun, caching)"
  type = list(object({
    storage_account_type = optional(string, "StandardSSD_LRS")
    create_option        = optional(string, "Empty")
    disk_size_gb         = optional(number, 128)
    lun                  = optional(number)
    caching              = optional(string, "None")
  }))
  default = []
}

# Tags Variable
variable "compute_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Boot Diagnostics Variables
variable "compute_boot_diagnostics_enabled" {
  description = "Enable or disable boot diagnostics"
  type        = bool
  default     = true
}

variable "compute_boot_diagnostics_storage_account_uri" {
  description = "Storage account URI for boot diagnostics. If not provided, a managed storage account will be used"
  type        = string
  default     = ""
}

# Backup Integration Variables
variable "compute_backup_policy_id" {
  description = "ID of a backup policy to assign to the VM (optional)"
  type        = string
  default     = ""
}

variable "compute_backup_enabled" {
  description = "Boolean flag to indicate if the VM should be setup for backup"
  type        = bool
  default     = false
}

# Additional VM Configuration Variables
variable "compute_availability_set_id" {
  description = "ID of the availability set to add the VM to"
  type        = string
  default     = ""
}

variable "compute_availability_zone" {
  description = "Availability zone to deploy the VM into"
  type        = string
  default     = null
}

variable "compute_identity_type" {
  description = "Type of identity to assign to the VM (SystemAssigned, UserAssigned, SystemAssigned, UserAssigned, or None)"
  type        = string
  default     = "SystemAssigned"
}

variable "compute_user_assigned_identities" {
  description = "Map of user-assigned identities to be attached to the VM"
  type        = map(string)
  default     = {}
}
