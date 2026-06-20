# TechUStart: servidor web Apache en Azure con Terraform

Este proyecto crea una máquina virtual Ubuntu 22.04 LTS en Microsoft Azure. Terraform aprovisiona la red, una IP pública, un grupo de seguridad y la VM; durante el primer arranque, `cloud_init.sh` instala Apache y publica una página de prueba.

## Arquitectura creada

- Resource Group.
- Virtual Network y Subnet.
- Public IP estática de SKU Standard.
- Network Security Group con una única regla entrante explícita: TCP/80 (HTTP).
- Network Interface asociada al NSG.
- Máquina virtual Linux Ubuntu con autenticación mediante clave pública SSH.
- Apache instalado y configurado automáticamente.

> Por el principio de menor privilegio, el puerto 22 no se abre a Internet. La clave SSH se configura como credencial de la VM, pero no habrá acceso SSH público mientras no se agregue una regla restringida y autorizada para ese fin.

## Requisitos previos

- Una cuenta y suscripción activa de Azure.
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli).
- Terraform 1.9.0 o posterior dentro de la rama 1.x, según el rango fijado por el proyecto.
- OpenSSH para generar la clave pública.

## Estructura

```text
.
├── .gitignore
├── README.md
├── cloud_init.sh
├── main.tf
├── outputs.tf
├── terraform.tfvars.example
└── variables.tf
```

## Ejecución

Todos los comandos siguientes deben ejecutarse desde la raíz de este proyecto.

### 1. Iniciar sesión en Azure

```bash
az login
```

Consulte sus suscripciones y seleccione la que desea utilizar:

```bash
az account list --output table
az account set --subscription "ID_O_NOMBRE_DE_LA_SUSCRIPCION"
```

### 2. Configurar la suscripción mediante una variable de entorno

En Bash, zsh o Git Bash:

```bash
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
```

En PowerShell:

```powershell
$env:ARM_SUBSCRIPTION_ID = "00000000-0000-0000-0000-000000000000"
```

No guarde el identificador de suscripción ni otras credenciales en los archivos `.tf`.

### 3. Generar una clave SSH

Si aún no dispone de una clave, genere una sin sobrescribir claves existentes:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
```

Terraform utilizará por defecto `~/.ssh/id_rsa.pub`. Solo se lee la clave pública; la clave privada nunca debe incorporarse al proyecto.

### 4. Configurar las variables

En Linux, macOS o Git Bash:

```bash
cp terraform.tfvars.example terraform.tfvars
```

En PowerShell:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edite `terraform.tfvars` si necesita cambiar la región, el tamaño de la VM, el usuario o la ruta de la clave pública. Este archivo está excluido por `.gitignore`.

### 5. Inicializar Terraform

```bash
terraform init
```

El archivo `.terraform.lock.hcl` generado por este comando debe conservarse en el control de versiones.

### 6. Formatear y validar

```bash
terraform fmt -recursive
terraform validate
```

### 7. Crear y revisar el plan

```bash
terraform plan -out=tfplan
```

### 8. Aplicar el plan

```bash
terraform apply tfplan
```

Al finalizar, Terraform mostrará `public_ip_address` y `web_url`. La instalación inicial puede tardar unos minutos.

### 9. Probar el sitio web

Obtenga la URL cuando lo necesite:

```bash
terraform output -raw web_url
```

Abra esa URL en un navegador. Debe mostrarse el mensaje:

> Servidor web TechUStart desplegado con Terraform

También puede probarla desde una terminal:

```bash
curl "$(terraform output -raw web_url)"
```

### 10. Destruir la infraestructura

Cuando termine la práctica, elimine los recursos para evitar cargos:

```bash
terraform destroy
```

Revise el plan de destrucción y confirme escribiendo `yes`.

## Seguridad y buenas prácticas

- El código no contiene contraseñas, claves de acceso ni identificadores de suscripción.
- La autenticación administrativa usa únicamente una clave pública SSH.
- El NSG solo permite tráfico HTTP entrante en el puerto 80.
- Los valores que pueden cambiar se definen mediante variables.
- Terraform y el proveedor `azurerm` tienen versiones exactas fijadas.
- Los recursos principales incluyen la etiqueta `Name` y etiquetas comunes de proyecto, entorno y administración.
- Los archivos de estado y variables locales no deben subirse al repositorio.
