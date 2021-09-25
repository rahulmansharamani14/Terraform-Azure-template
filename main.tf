# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}

# Create a new resource group
resource "azurerm_resource_group" "myterraformgroup" {
  name     = "myResourceGroup"
  location = "eastus"

  tags = {
    environment = "IaC Demo"
  }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myterraformgroup.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  tags = {
    environment = "IaC Demo"
  }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.myterraformgroup.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "IaC Demo"
  }
}

# Create Network Security Group
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.myterraformgroup.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "IaC Demo"
  }
}

# Create network interface card
resource "azurerm_network_interface" "myterraformnic" {
  name                = "myNIC"
  location            = azurerm_resource_group.myterraformgroup.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.myterraformsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }

  tags = {
    environment = "IaC Demo"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "myterraformconnect" {
  network_interface_id      = azurerm_network_interface.myterraformnic.id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "mystorage14082002"
  resource_group_name      = azurerm_resource_group.myterraformgroup.name
  location                 = azurerm_resource_group.myterraformgroup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "IaC Demo"
  }
}

# Create an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
  name                            = "myVM"
  location                        = azurerm_resource_group.myterraformgroup.location
  resource_group_name             = azurerm_resource_group.myterraformgroup.name
  network_interface_ids           = [azurerm_network_interface.myterraformnic.id]
  size                            = "Standard_DS1_v2"
  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }


  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  }

  tags = {
    environment = "IaC Demo"
  }
}