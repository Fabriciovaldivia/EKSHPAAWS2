#!/bin/bash
echo "🚀 Desplegando ACME EKS Platform..."

# 1. Terraform
echo "📦 Creando infraestructura..."
cd "$(dirname "$0")/.."   # sube desde /scripts a la raíz del proyecto
terraform init
terraform apply -auto-approve

# 2. Configurar kubectl
echo "⚙️ Configurando kubectl..."
aws eks update-kubeconfig --region us-east-1 --name acme-eks

# 3. Aplicar manifests
echo "🐳 Desplegando aplicación..."
kubectl apply -f k8s-manifests/

# 3.1 Instalar metrics-server
echo "📊 Instalando metrics-server..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 4. Verificar
echo "✅ Verificando despliegue..."
kubectl wait --for=condition=ready pod -l app=nginx --timeout=180s
kubectl get pods
kubectl get service nginx-service

echo "🎉 ¡Despliegue completado!"
