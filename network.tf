# Resource group
resource "azurerm_resource_group" "resourcegroup" {
    name     = "ad-lab-resource-group"
    location = "southcentralus"
}

# Virtual network 10.0.0.0/16
resource "azurerm_virtual_network" "network" {
  name                = "virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
}

# Subnet 10.0.0.0/24
resource "azurerm_subnet" "internal" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.0.0.0/24"]
}
resource "azurerm_public_ip" "domain-controller" {
  name                    = "DC-1"  
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

}
resource "azurerm_public_ip" "domain-controller-2" {
  name                    = "DC-2"  
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

}

# Network interface for the DC
resource "azurerm_network_interface" "domain-controller-2" {
  name                = "domain-controller-nic-2"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  ip_configuration {
    name                          = "dc-2"resource "azurerm_network_interface" "domain-controller-2" {
  name                = "domain-controller-nic"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  ip_configuration {
    name                          = "dc-2"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.0.11"
    public_ip_address_id  = azurerm_public_ip.domain-controller-2.id
  }
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.0.10"
    public_ip_address_id  = azurerm_public_ip.domain-controller.id
  }
    
}
