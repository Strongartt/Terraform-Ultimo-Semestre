variable "azure_region" {
  description = "Región de Azure donde se crearán los recursos."
  type        = string
  default     = "eastus"
}

variable "tamano_vm" {
  description = "Tamaño de la máquina virtual Linux."
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Nombre del usuario administrador de la máquina virtual."
  type        = string
  default     = "azureadmin"

  validation {
    condition     = can(regex("^[a-z_][a-z0-9_-]{0,31}$", var.admin_username))
    error_message = "admin_username debe comenzar con una letra minúscula o guion bajo y usar solo minúsculas, números, guiones o guiones bajos."
  }
}

variable "ssh_public_key_path" {
  description = "Ruta local al archivo que contiene la clave pública SSH."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "project_name" {
  description = "Nombre corto del proyecto, usado para nombrar y etiquetar recursos."
  type        = string
  default     = "techustart"
}

variable "environment" {
  description = "Nombre del entorno de despliegue."
  type        = string
  default     = "dev"
}

variable "vnet_address_space" {
  description = "Espacio de direcciones CIDR de la red virtual."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_address_prefix" {
  description = "Prefijo CIDR de la subred."
  type        = string
  default     = "10.0.1.0/24"
}
