provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "webserver" {
  name = "${var.prefix}-rg"
  location = var.location
  tags = {
    "project": "udacity-azure-devops-nanodegree-project-1"
  }
}

resource "azurerm_virtual_network" "webserver" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.webserver.location
  resource_group_name = azurerm_resource_group.webserver.name
  tags = {
    "project": "udacity-azure-devops-nanodegree-project-1"
  }
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.webserver.name
  virtual_network_name = azurerm_virtual_network.webserver.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "webserver" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.webserver.location
  resource_group_name = azurerm_resource_group.webserver.name
  tags = {
    "project": "udacity-azure-devops-nanodegree-project-1"
  }
  security_rule {
    name                       = "AllowOutboundSameSubnet"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "AzureLoadBalancer"
  }

  security_rule {
    name                       = "AllowInboundSameSubnet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "AzureLoadBalancer"
  }

  security_rule {
    name                       = "DenyInboundInternet"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  tags = {
    "project": "udacity-azure-devops-nanodegree-project-1"
  }
}

resource "azurerm_network_interface" "webserver" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.webserver.name
  location            = azurerm_resource_group.webserver.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    "project": "udacity-azure-devops-nanodegree-project-1"
  }
}

resource "azurerm_public_ip" "webserver" {
  name                = "${var.prefix}-public-ip"
  location            = azurerm_resource_group.webserver.location
  resource_group_name = azurerm_resource_group.webserver.name
  allocation_method   = "Static"
  domain_name_label   = "${var.prefix}-public-ip"
  tags = {
    "project": "udacity-azure-devops-nanodegree-project-1"
  }
}

resource "azurerm_lb" "webserver" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.webserver.location
  resource_group_name = azurerm_resource_group.webserver.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.webserver.id
  }
  tags = {
    "project": "udacity-azure-devops-nanodegree-project-1"
  }
}

resource "azurerm_lb_backend_address_pool" "webserver" {
    resource_group_name = azurerm_resource_group.webserver.name
    loadbalancer_id     = azurerm_lb.webserver.id
    name                = "BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "webserver" {
    network_interface_id    = azurerm_network_interface.webserver.id
    ip_configuration_name   = "internal"
    backend_address_pool_id =azurerm_lb_backend_address_pool.webserver.id
}

resource "azurerm_availability_set" "webserver" {
    name                = "${var.prefix}-availabilityset"
    location            = azurerm_resource_group.webserver.location
    resource_group_name = azurerm_resource_group.webserver.name
    tags = {
      "project": "udacity-azure-devops-nanodegree-project-1"
    }
}

resource "azurerm_linux_virtual_machine" "webserver" {
  count                           = var.vm-count
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.webserver.name
  location                        = azurerm_resource_group.webserver.location
  availability_set_id              = azurerm_availability_set.webserver.id
  network_interface_ids           = [azurerm_network_interface.webserver.id]
  size                            = "Standard_D2s_v3"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  source_image_id                 = var.packer_image
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

resource "azurerm_managed_disk" "webserver" {
  name                 = "${var.prefix}-vm-disk"
  location             = azurerm_resource_group.webserver.location
  resource_group_name  = azurerm_resource_group.webserver.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"

  tags = {
    "project": "udacity-azure-devops-nanodegree-project-1"
  }
}
