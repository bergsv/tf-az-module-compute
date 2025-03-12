# Linux VM Example with Data Disk
# -------------------------------

provider "azurerm" {
  features {}
}

# Create a basic network environment
resource "azurerm_resource_group" "network_rg" {
  name     = "rg-network-linux-example"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-linux-example"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "snet-linux-example"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

# Generate an SSH key for Linux VM authentication
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key to a local file (for demo purposes only)
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/id_rsa"
}

# Deploy a Linux VM with data disk
module "linux_vm" {
  source = "../"
  
  # Resource group settings
  compute_create_resource_group = true
  compute_resource_group_name   = "rg-linux-example"
  compute_location              = "eastus"
  
  # Network settings
  compute_nic_name              = "nic-linux"
  compute_subnet_id             = azurerm_subnet.subnet.id
  
  # VM settings
  compute_vm_name               = "vm-linux"
  compute_vm_size               = "Standard_B2s_v3"
  compute_os_type               = "linux"
  
  # Linux specific settings
  compute_admin_username        = "linuxadmin"
  compute_ssh_public_key        = tls_private_key.ssh_key.public_key_openssh
  
  # Image settings (Ubuntu)
  compute_image_publisher       = "Canonical"
  compute_image_offer           = "UbuntuServer"
  compute_image_sku             = "18.04-LTS"
  compute_image_version         = "latest"
  
  # Data disk settings
  compute_data_disks = [
    {
      disk_size_gb         = 100
      storage_account_type = "StandardSSD_LRS"
      lun                  = 10
      caching              = "ReadWrite"
    }
  ]
  
  # Enable boot diagnostics with managed storage
  compute_boot_diagnostics_enabled = true
  
  # Add system-assigned identity for Azure services access
  compute_identity_type = "SystemAssigned"
  
  # Tags
  compute_tags = {
    environment = "dev"
    os          = "linux"
  }
}

# Output connection information
output "vm_private_ip" {
  value = module.linux_vm.private_ip_address
}

output "ssh_command" {
  value = "ssh ${module.linux_vm.computer_name}@${module.linux_vm.private_ip_address} -i id_rsa"
}

output "principal_id" {
  value = module.linux_vm.vm_principal_id
  description = "The Principal ID of the VM's system-assigned identity"
}
