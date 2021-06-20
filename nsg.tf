# Note: you'll need to run 'terraform init' before terraform apply-ing this, because 'http' is a new provider

# Dynamically retrieve our public outgoing IP
data "http" "outgoing_ip" {
  url = "http://ipv4.icanhazip.com"
}
locals {
  outgoing_ip = chomp(data.http.outgoing_ip.body)
}

# Network security group
resource "azurerm_network_security_group" "domain_controller" {
  name                = "domain-controller-nsg"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  # RDP
  security_rule {
    name                       = "Allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${local.outgoing_ip}/32"
    destination_address_prefix = "*"
  }

  # WinRM
  security_rule {
    name                       = "Allow-WinRM"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = "${local.outgoing_ip}/32"
    destination_address_prefix = "*"
  }
}

# Associate our network security group with the NIC of our domain controller
resource "azurerm_network_interface_security_group_association" "domain_controller" {
  network_interface_id      = azurerm_network_interface.domain-controller.id
  network_security_group_id = azurerm_network_security_group.domain_controller.id
}
