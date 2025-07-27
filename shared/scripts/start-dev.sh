#!/bin/bash

# Development Environment Startup Script
# Usage: ./shared/scripts/start-dev.sh [mode]
# Modes: local, docker, e2e

set -e

MODE=${1:-local}
PROJECT_ROOT=$(dirname $(dirname $(realpath $0)))

echo "🚀 Vue-Chi Development Environment Startup"
echo "Project Root: $PROJECT_ROOT"
echo "Mode: $MODE"

cd "$PROJECT_ROOT"

case $MODE in
    "local")
        echo "🔧 Starting local development environment..."
        
        # Start backend
        echo "Starting backend..."
        cd backend
        make dev &
        BACKEND_PID=$!
        cd ..
        
        # Start frontend
        echo "Starting frontend..."
        cd frontend
        npm run dev &
        FRONTEND_PID=$!
        cd ..
        
        echo "✅ Local development environment started"
        echo "Backend: http://localhost:8080"
        echo "Frontend: http://localhost:5173"
        echo "Press Ctrl+C to stop both services"
        
        # Wait for interrupt signal
        trap "echo 'Stopping services...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null || true; exit 0" INT
        wait
        ;;
        
    "docker")
        echo "🐳 Starting Docker development environment..."
        docker compose -f shared/docker/docker-compose.yml up --build
        ;;
        
    "e2e")
        echo "🧪 Starting E2E testing environment..."
        docker compose -f shared/docker/docker-compose.e2e.yml up -d --build
        
        echo "✅ E2E environment started"
        echo "Backend: http://localhost:8080"
        echo "Frontend: http://localhost:5173"
        echo "Database: localhost:15435"
        echo "PgAdmin: http://localhost:5050"
        echo ""
        echo "Run E2E tests with: ./shared/scripts/e2e-test.sh"
        ;;
        
    *)
        echo "❌ Unknown mode: $MODE"
        echo "Available modes: local, docker, e2e"
        exit 1
        ;;
esac