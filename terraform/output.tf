# Datos de acceso del ACR
output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
  description = "Hostname del ACR"
}
output "acr_admin_username" {
  value = azurerm_container_registry.acr.admin_username
  description = "Nombre del usuario administrador del ACR"
}
output "acr_admin_password" {
  value = azurerm_container_registry.acr.admin_password
  description = "Password del usuario administrador del ACR"
  sensitive = true
}

# Datos de acceso a la VM
resource "ansible_host" "host" {
  name   = "vm"
  variables = {
    ansible_host = azurerm_linux_virtual_machine.vm.public_ip_address
  }
}
output "vm_ip" {
  value       = azurerm_linux_virtual_machine.vm.public_ip_address
  description = "Dirección IP pública de la vm"
}
output "vm_admin_username" {
  value       = var.admin_username
  description = "Usuario administrador para la vm"
}
output "vm_admin_private_key" {
  value = tls_private_key.admin_private_key.private_key_pem
  description = "Private Key del usuario administrador para vm"
  sensitive = true
}

# Datos de acceso al AKS
output "aks_kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  description = "Fichero kube_config para el acceso al AKS"
  sensitive = true
}