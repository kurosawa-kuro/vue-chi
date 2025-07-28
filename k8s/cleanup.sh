#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

CLUSTER_NAME="vue-chi-staging"

echo -e "${BLUE}🧹 Vue-Chi Kubernetes Staging Environment Cleanup${NC}"
echo "================================================="

# Delete Kind cluster
echo -e "${YELLOW}🗑️  Deleting Kind cluster...${NC}"
if kind get clusters | grep -q "$CLUSTER_NAME"; then
    kind delete cluster --name "$CLUSTER_NAME"
    echo -e "${GREEN}✅ Cluster $CLUSTER_NAME deleted successfully${NC}"
else
    echo -e "${YELLOW}⚠️  Cluster $CLUSTER_NAME does not exist${NC}"
fi

# Remove Docker images
echo -e "${YELLOW}🗑️  Removing Docker images...${NC}"
if docker images -q vue-chi-backend:staging >/dev/null 2>&1; then
    docker rmi vue-chi-backend:staging && echo -e "${GREEN}✅ Backend image removed${NC}"
else
    echo -e "${YELLOW}⚠️  Backend image not found${NC}"
fi

if docker images -q vue-chi-frontend:staging >/dev/null 2>&1; then
    docker rmi vue-chi-frontend:staging && echo -e "${GREEN}✅ Frontend image removed${NC}"
else
    echo -e "${YELLOW}⚠️  Frontend image not found${NC}"
fi

# Note: Hosts cleanup is now manual if needed

echo -e "${GREEN}🎉 Cleanup completed successfully!${NC}"