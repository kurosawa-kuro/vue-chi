#!/bin/bash

# E2E Test Execution Script
# Usage: ./shared/scripts/e2e-test.sh [browser] [test-file]

set -e

# Default values
BROWSER=${1:-chromium}
TEST_FILE=${2:-""}
PROJECT_ROOT=$(dirname $(dirname $(dirname $(realpath $0))))

echo "🎭 Vue-Chi E2E Testing Script"
echo "Project Root: $PROJECT_ROOT"
echo "Browser: $BROWSER"
echo "Test File: ${TEST_FILE:-"All tests"}"

# Function to check if service is running
check_service() {
    local url=$1
    local name=$2
    echo "Checking $name at $url..."
    if curl -s -f "$url" > /dev/null; then
        echo "✅ $name is running"
        return 0
    else
        echo "❌ $name is not accessible"
        return 1
    fi
}

# Function to wait for service
wait_for_service() {
    local url=$1
    local name=$2
    local max_attempts=30
    local attempt=1
    
    echo "Waiting for $name to be ready..."
    while [ $attempt -le $max_attempts ]; do
        if check_service "$url" "$name"; then
            return 0
        fi
        echo "Attempt $attempt/$max_attempts - waiting 3 seconds..."
        sleep 3
        attempt=$((attempt + 1))
    done
    
    echo "❌ $name failed to start after $max_attempts attempts"
    return 1
}

# Navigate to project root
cd "$PROJECT_ROOT"

# Check if Docker environment is running
echo "📊 Checking Docker environment..."
if docker compose -f shared/docker/docker-compose.e2e.yml ps | grep -q "Up"; then
    echo "✅ Docker E2E environment is running"
    
    # Check services
    wait_for_service "http://localhost:8080/api/health" "Backend API"
    wait_for_service "http://localhost:5173" "Frontend"
    
    export PLAYWRIGHT_BASE_URL="http://localhost:5173"
else
    echo "❌ Docker E2E environment is not running"
    echo "Starting E2E environment..."
    
    # Start E2E environment
    docker compose -f shared/docker/docker-compose.e2e.yml up -d --build backend frontend db
    
    # Wait for services
    wait_for_service "http://localhost:8080/api/health" "Backend API"
    wait_for_service "http://localhost:5173" "Frontend"
    
    export PLAYWRIGHT_BASE_URL="http://localhost:5173"
fi

# Navigate to frontend directory
cd frontend

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing frontend dependencies..."
    npm ci
fi

# Create clean test results directory
echo "🧹 Preparing test environment..."
rm -rf test-results playwright-report 2>/dev/null || true
mkdir -p test-results playwright-report

# Run Playwright tests
echo "🎭 Running Playwright E2E tests..."
if [ -n "$TEST_FILE" ]; then
    echo "Running specific test: $TEST_FILE"
    npx playwright test "$TEST_FILE" --project="$BROWSER" --workers=1 --reporter=line
else
    echo "Running all E2E tests"
    npx playwright test --project="$BROWSER" --workers=1 --reporter=line
fi

# Show results
echo "📋 Test execution completed"
echo "Results location: frontend/test-results/"

# Generate report if available
if [ -d "test-results" ]; then
    echo "📊 Generating HTML report..."
    npx playwright show-report --host 0.0.0.0 --port 9323 &
    echo "Report available at: http://localhost:9323"
fi