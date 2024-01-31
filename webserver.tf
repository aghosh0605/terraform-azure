terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.77.0"
    }
  }
}

provider "azurerm" {
     skip_provider_registration = "true"
  features {
    
  }
}

resource "azurerm_resource_group" "resource_group" {
  name     = "terraform-resources"
  location = "westindia"
}

resource "azurerm_virtual_network" "azure_vpc" {
  name                = "azure-vpc-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "vpc_subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.azure_vpc.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "public_ip_vm" {
  name                = "vm_public_ip"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "subnet_interface" {
  name                = "vm-nic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vpc_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip_vm.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "ssh_nsg_vm"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  security_rule {
    name                       = "allow_ssh_sg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "association_public" {
  network_interface_id      = azurerm_network_interface.subnet_interface.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm_instance" {
  name                = "vm-machine"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "Standard_B2ms"
  admin_username      = "ubuntu"
  # zone = 1
  network_interface_ids = [
    azurerm_network_interface.subnet_interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

    admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/HTBSRMIST_Lightsail.pub")
  }
}

output "public_ip" {
  value = azurerm_public_ip.public_ip_vm.ip_address
}