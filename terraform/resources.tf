resource "azurerm_resource_group" "rg" {
  name     = "cp2_rg"
  location = var.location
}

//////// ACR ////////
resource "azurerm_container_registry" "acr" {
  name                = "cp2obfQ0982O3BW"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}

//////// VM ////////
resource "tls_private_key" "admin_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "azurerm_network_interface" "vm_nic" {
  name                = "cp2_vm_nic1"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "public"
    subnet_id                     = azurerm_subnet.priv_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "cp2vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  disable_password_authentication = true
  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.admin_private_key.public_key_openssh
  }
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

//////// AKS ////////
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "cp2aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "cp2aks"
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }
  identity {
    type = "SystemAssigned"
  }
}

//////// Permisos pull de AKS a ACR ////////
resource "azurerm_role_assignment" "aks_to_acr" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}