#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="vue-chi-staging"
NAMESPACE="vue-chi-staging"
BACKEND_IMAGE="vue-chi-backend:staging"
FRONTEND_IMAGE="vue-chi-frontend:staging"

echo -e "${BLUE}🚀 Vue-Chi Kubernetes Staging Environment Deployment${NC}"
echo "=================================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

if ! command_exists kind; then
    echo -e "${RED}❌ Kind is not installed. Please install Kind first.${NC}"
    echo "Visit: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
    exit 1
fi

if ! command_exists kubectl; then
    echo -e "${RED}❌ kubectl is not installed. Please install kubectl first.${NC}"
    echo "Visit: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

if ! command_exists docker; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All prerequisites satisfied${NC}"

# Create Kind cluster
echo -e "${YELLOW}🔧 Creating Kind cluster...${NC}"
if kind get clusters | grep -q "$CLUSTER_NAME"; then
    echo -e "${YELLOW}⚠️  Cluster $CLUSTER_NAME already exists. Deleting...${NC}"
    kind delete cluster --name "$CLUSTER_NAME"
fi

kind create cluster --config k8s/kind-config.yaml --name "$CLUSTER_NAME"
echo -e "${GREEN}✅ Kind cluster created successfully${NC}"

# Set kubectl context
kubectl cluster-info --context kind-"$CLUSTER_NAME"

# Install NGINX Ingress Controller
echo -e "${YELLOW}🔧 Installing NGINX Ingress Controller...${NC}"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for NGINX Ingress to be ready
echo -e "${YELLOW}⏳ Waiting for NGINX Ingress Controller to be ready...${NC}"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Build Docker images
echo -e "${YELLOW}🔨 Building Docker images...${NC}"

# Build backend image
echo -e "${BLUE}Building backend image...${NC}"
cd backend
docker build -f docker/Dockerfile -t "$BACKEND_IMAGE" .
cd ..

# Build frontend image
echo -e "${BLUE}Building frontend image...${NC}"
cd frontend
docker build -f docker/Dockerfile -t "$FRONTEND_IMAGE" .
cd ..

# Load images into Kind cluster
echo -e "${YELLOW}📦 Loading images into Kind cluster...${NC}"
kind load docker-image "$BACKEND_IMAGE" --name "$CLUSTER_NAME"
kind load docker-image "$FRONTEND_IMAGE" --name "$CLUSTER_NAME"

echo -e "${GREEN}✅ Images loaded successfully${NC}"

# Deploy to Kubernetes
echo -e "${YELLOW}🚀 Deploying to Kubernetes...${NC}"

# Apply manifests in order
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/postgres-init-configmap.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/ingress.yaml

# Wait for deployments to be ready
echo -e "${YELLOW}⏳ Waiting for deployments to be ready...${NC}"

kubectl wait --for=condition=available --timeout=300s deployment/postgres-deployment -n "$NAMESPACE"
kubectl wait --for=condition=available --timeout=300s deployment/backend-deployment -n "$NAMESPACE"
kubectl wait --for=condition=available --timeout=300s deployment/frontend-deployment -n "$NAMESPACE"

echo -e "${GREEN}✅ All deployments are ready${NC}"

# Note: Hosts configuration is now manual - see README.md for instructions

# Display status
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo "=================================================="
echo -e "${BLUE}📊 Cluster Information:${NC}"
echo "  Cluster Name: $CLUSTER_NAME"
echo "  Namespace: $NAMESPACE"
echo ""
echo -e "${BLUE}🌐 Access URLs:${NC}"
echo "  Frontend: http://vue-chi-staging.local"
echo "  Backend API: http://vue-chi-staging.local/api"
echo ""
echo -e "${BLUE}📋 Useful Commands:${NC}"
echo "  Check pods: kubectl get pods -n $NAMESPACE"
echo "  Check services: kubectl get services -n $NAMESPACE"
echo "  Check ingress: kubectl get ingress -n $NAMESPACE"
echo "  View logs: kubectl logs -f deployment/backend-deployment -n $NAMESPACE"
echo "  Delete cluster: kind delete cluster --name $CLUSTER_NAME"
echo ""
echo -e "${YELLOW}⚠️  Note: Make sure port 80 and 443 are available on your system${NC}"