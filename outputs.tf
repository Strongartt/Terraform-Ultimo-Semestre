output "public_ip_address" {
  description = "Dirección IP pública de la máquina virtual."
  value       = azurerm_public_ip.techustart.ip_address
}

output "web_url" {
  description = "URL pública del servidor web Apache."
  value       = "http://${azurerm_public_ip.techustart.ip_address}"
}
