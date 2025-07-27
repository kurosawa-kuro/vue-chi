#!/bin/bash

# Docker Environment Configuration
# Common environment variables and functions for Docker setup

# Project paths
export PROJECT_ROOT=$(dirname $(dirname $(realpath $0)))
export BACKEND_DIR="$PROJECT_ROOT/backend"
export FRONTEND_DIR="$PROJECT_ROOT/frontend"
export SHARED_DIR="$PROJECT_ROOT/shared"

# Docker configuration
export COMPOSE_PROJECT_NAME="vue-chi"
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Database configuration
export POSTGRES_USER="sampleuser"
export POSTGRES_PASSWORD="samplepass"
export POSTGRES_DB="sampledb"
export DB_PORT_DEV="15432"
export DB_PORT_E2E="15435"
export DB_PORT_TEST="15434"

# Application ports
export BACKEND_PORT="8080"
export FRONTEND_PORT="5173"
export PGADMIN_PORT="5050"

# API configuration
export API_BASE_URL="http://localhost:${BACKEND_PORT}"
export VITE_API_BASE_URL="http://backend:${BACKEND_PORT}"

# Test configuration
export PLAYWRIGHT_BASE_URL="http://localhost:${FRONTEND_PORT}"
export E2E_TIMEOUT="120000"

# Color codes for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m' # No Color

# Utility functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    log_success "Docker is running"
}

# Check if port is available
check_port() {
    local port=$1
    local service=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        log_warning "Port $port is already in use (required for $service)"
        return 1
    else
        log_success "Port $port is available for $service"
        return 0
    fi
}

# Wait for service to be ready
wait_for_service() {
    local url=$1
    local service_name=$2
    local max_attempts=${3:-30}
    local attempt=1
    
    log_info "Waiting for $service_name to be ready at $url..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "$url" > /dev/null 2>&1; then
            log_success "$service_name is ready"
            return 0
        fi
        
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo ""
    log_error "$service_name failed to start after $max_attempts attempts"
    return 1
}

# Clean up Docker resources
cleanup_docker() {
    local compose_file=$1
    log_info "Cleaning up Docker resources..."
    
    if [ -f "$compose_file" ]; then
        docker compose -f "$compose_file" down -v --remove-orphans 2>/dev/null || true
    fi
    
    # Clean up orphaned containers
    docker container prune -f >/dev/null 2>&1 || true
    docker volume prune -f >/dev/null 2>&1 || true
    
    log_success "Docker cleanup completed"
}