# Basic VM Example - Demonstrates the simplest way to use this module
# ---------------------------------------------------------------------

# Provider configuration - Replace with your own subscription ID
provider "azurerm" {
  features {}
  # subscription_id = "your-subscription-id"
}

# Network prerequisites
resource "azurerm_resource_group" "network_rg" {
  name     = "rg-network-example"
  location = "westeurope"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "snet-example"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Call the VM module - Windows VM
module "windows_vm" {
  source = "../"  # Path to the module (adjust as needed)
  
  # Resource group settings
  compute_create_resource_group = true
  compute_resource_group_name   = "rg-vm-example"
  compute_location              = "westeurope"
  
  # Network settings
  compute_nic_name              = "nic-example"
  compute_subnet_id             = azurerm_subnet.subnet.id
  compute_private_ip_allocation = "Dynamic"
  
  # VM settings
  compute_vm_name               = "vm-example"
  compute_vm_size               = "Standard_B2s_v3"
  compute_os_type               = "windows"
  
  # Authentication
  compute_admin_username        = "adminuser"
  compute_admin_password        = "P@ssw0rd1234!"  # In production, use a variable or key vault
  
  # Tags
  compute_tags = {
    environment = "dev"
    purpose     = "example"
  }
}

# Output the VM details
output "vm_private_ip" {
  value = module.windows_vm.private_ip_address
}

output "resource_group_name" {
  value = module.windows_vm.resource_group_name
}
