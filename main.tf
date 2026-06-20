terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.117.1"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  resource_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
  }
}

resource "azurerm_resource_group" "techustart" {
  name     = "rg-${local.resource_prefix}"
  location = var.azure_region

  tags = merge(local.common_tags, {
    Name = "rg-${local.resource_prefix}"
  })
}

resource "azurerm_virtual_network" "techustart" {
  name                = "vnet-${local.resource_prefix}"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.techustart.location
  resource_group_name = azurerm_resource_group.techustart.name

  tags = merge(local.common_tags, {
    Name = "vnet-${local.resource_prefix}"
  })
}

resource "azurerm_subnet" "techustart" {
  name                 = "snet-${local.resource_prefix}"
  resource_group_name  = azurerm_resource_group.techustart.name
  virtual_network_name = azurerm_virtual_network.techustart.name
  address_prefixes     = [var.subnet_address_prefix]
}

resource "azurerm_public_ip" "techustart" {
  name                = "pip-${local.resource_prefix}"
  resource_group_name = azurerm_resource_group.techustart.name
  location            = azurerm_resource_group.techustart.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(local.common_tags, {
    Name = "pip-${local.resource_prefix}"
  })
}

resource "azurerm_network_security_group" "techustart" {
  name                = "nsg-${local.resource_prefix}"
  resource_group_name = azurerm_resource_group.techustart.name
  location            = azurerm_resource_group.techustart.location

  security_rule {
    name                       = "allow_http_inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(local.common_tags, {
    Name = "nsg-${local.resource_prefix}"
  })
}

resource "azurerm_network_interface" "techustart" {
  name                = "nic-${local.resource_prefix}"
  resource_group_name = azurerm_resource_group.techustart.name
  location            = azurerm_resource_group.techustart.location

  ip_configuration {
    name                          = "ipconfig-${local.resource_prefix}"
    subnet_id                     = azurerm_subnet.techustart.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.techustart.id
  }

  tags = merge(local.common_tags, {
    Name = "nic-${local.resource_prefix}"
  })
}

resource "azurerm_network_interface_security_group_association" "techustart" {
  network_interface_id      = azurerm_network_interface.techustart.id
  network_security_group_id = azurerm_network_security_group.techustart.id
}

resource "azurerm_linux_virtual_machine" "techustart" {
  name                            = "vm-${local.resource_prefix}"
  resource_group_name             = azurerm_resource_group.techustart.name
  location                        = azurerm_resource_group.techustart.location
  size                            = var.tamano_vm
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.techustart.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(file("${path.module}/cloud_init.sh"))

  tags = merge(local.common_tags, {
    Name = "vm-${local.resource_prefix}"
  })
}
