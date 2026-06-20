#!/bin/bash
set -euo pipefail

sudo apt update -y
sudo apt install apache2 -y
sudo systemctl enable apache2

sudo tee /var/www/html/index.html > /dev/null <<'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>TechUStart</title>
</head>
<body>
  <h1>Servidor web TechUStart desplegado con Terraform</h1>
</body>
</html>
EOF

sudo systemctl start apache2
