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
docker rmi vue-chi-backend:staging 2>/dev/null || echo -e "${YELLOW}⚠️  Backend image not found${NC}"
docker rmi vue-chi-frontend:staging 2>/dev/null || echo -e "${YELLOW}⚠️  Frontend image not found${NC}"

# Remove hosts entry
echo -e "${YELLOW}🗑️  Removing hosts entry...${NC}"
if grep -q "vue-chi-staging.local" /etc/hosts; then
    sudo sed -i '/vue-chi-staging.local/d' /etc/hosts
    echo -e "${GREEN}✅ Removed vue-chi-staging.local from /etc/hosts${NC}"
else
    echo -e "${YELLOW}⚠️  vue-chi-staging.local not found in /etc/hosts${NC}"
fi

echo -e "${GREEN}🎉 Cleanup completed successfully!${NC}"