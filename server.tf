# Note: you'll need to run 'terraform init' before terraform apply-ing this, because 'random_password' is a new provider
# Generate a Random password for our domain controller
resource "random_password" "domain_controller_password" {
  length = 16
}
# ... and make sure it's shown to us in the console output of 'terraform apply'
output "domain_controller_password" {
  value = random_password.domain_controller_password.result
  sensitive = true
}
# VM for our domain controller
resource "azurerm_virtual_machine" "domain_controller" {
  name                  = "domain-controller"
  location              = azurerm_resource_group.resourcegroup.location
  resource_group_name   = azurerm_resource_group.resourcegroup.name
  network_interface_ids = [azurerm_network_interface.domain-controller.id]
  # List of available sizes: https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs
  vm_size               = "Standard_D1_v2"
  # Base image
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  
  # Disk
  delete_os_disk_on_termination = true
  storage_os_disk {
    name              = "domain-controller-os-disk"
    create_option     = "FromImage"
  }
  os_profile {
    computer_name  = "DC-1"
    # Note: you can't use admin or Administrator in here, Azure won't allow you to do so :-)
    admin_username = "sequel-admin"
    admin_password = random_password.domain_controller_password.result
  }
  os_profile_windows_config {
    # Enable WinRM - we'll need to later
    winrm {
      protocol = "HTTP"
    }
  }
  tags = {
    kind = "domain_controller"
  }
}
