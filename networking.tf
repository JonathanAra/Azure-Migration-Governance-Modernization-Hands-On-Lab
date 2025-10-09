resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  address_space       = [var.vnet_cidr]
  tags                = { env = "lab" }
}

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = "${each.key}-snet"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
}

resource "azurerm_network_security_group" "nsg_management" {
  name                = "${var.prefix}-nsg-mgmt"
  location            = var.location
  resource_group_name = azurerm_resource_group.platform.name

  security_rule {
    name                       = "AllowSSHFromClient"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = [var.admin_public_ip_cidr]
    destination_address_prefix = "*"
  }

  tags = { env = "lab" }
}

resource "azurerm_subnet_network_security_group_association" "mgmt_assoc" {
  subnet_id                 = azurerm_subnet.subnets["management"].id
  network_security_group_id = azurerm_network_security_group.nsg_management.id
}
