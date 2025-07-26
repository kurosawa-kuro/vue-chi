# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Architecture

This is a full-stack web application with separate frontend and backend components:

- **Backend**: Go + Chi REST API (located in `backend/`)
- **Frontend**: Vue 3 + Vite + Tailwind CSS SPA (located in `frontend/`) 
- **Admin Template**: Nuxt 3 admin dashboard template (located in `template-admin/dashboard/`)

## Backend (Go + Chi)

**Working Directory**: Always navigate to `backend/` for backend operations.

### Development Commands

```bash
# Development (must be run from backend/)
make run                    # Run application locally
make dev                    # Run with hot reload (air)
make docker                 # Run with Docker Compose (includes PostgreSQL)
make docker-bg              # Run Docker Compose in background

# Building
make build                  # Build the application

# Testing
make test-setup             # Initial test setup (creates test DB)
make test                   # Run all tests (with DB setup if needed)
make test-only              # Run tests only (fast, assumes DB is running)
make test-coverage          # Run tests with coverage
make test-coverage-html     # Generate HTML coverage report

# Test Database Management
make test-db-up             # Start test database
make test-db-down           # Stop test database
make test-db-status         # Check test database status

# Environment
make env-init ENV=development  # Initialize environment files
```

### Architecture Overview

- **Layered Architecture**: Handler → Service → Model
- **Database**: PostgreSQL with migrations in `db/migrations/`
- **Testing**: Uses testify, httpexpect, and apitest libraries
- **Docker**: Development environment runs in containers
- **API Documentation**: Swagger/OpenAPI auto-generated

**Key Directories:**
- `src/handler/` - HTTP request handlers (Controller layer)
- `src/services/` - Business logic (Service layer)  
- `src/models/` - Data models and response structures
- `src/router/` - Route definitions
- `src/middleware/` - HTTP middleware
- `src/config/` - Configuration and database setup
- `src/test/` - Integration and unit tests
- `db/` - Database scripts and migrations

## Frontend (Vue 3)

**Working Directory**: Always navigate to `frontend/` for frontend operations.

### Development Commands

```bash
# Development (must be run from frontend/)
npm run dev                 # Start development server
npm run dev:mock           # Start dev server with MSW mocking enabled
npm run build              # Build for production
npm run preview            # Preview production build

# Testing
npm run test               # Run unit tests with Vitest
npm run test:ui            # Run tests with UI
npm run test:coverage      # Run tests with coverage report
```

### Architecture Overview

- **Framework**: Vue 3 with Composition API
- **State Management**: Pinia stores
- **Routing**: Vue Router
- **Styling**: Tailwind CSS
- **Testing**: Vitest + Vue Testing Library + MSW for mocking
- **Build Tool**: Vite

**Key Directories:**
- `src/components/` - Vue components (organized by feature)
- `src/stores/` - Pinia state stores
- `src/services/` - API service layer
- `src/mocks/` - MSW mock handlers for development/testing
- `src/pages/` - Page components
- `src/router/` - Route definitions
- `src/tests/` - Test setup and integration tests

### Mock Service Worker (MSW)

The frontend uses MSW for API mocking:
- Handlers defined in `src/mocks/handlers.js`
- Enabled in development with `VITE_ENABLE_MSW=true`
- Automatically enabled in tests

## Admin Template

**Working Directory**: Always navigate to `template-admin/dashboard/` for admin operations.

### Development Commands

```bash
# Development (must be run from template-admin/dashboard/)
pnpm dev                   # Start development server
pnpm build                 # Build for production
pnpm generate              # Generate static site
```

This is a Nuxt 3 admin dashboard template with TypeScript and UI components.

## Common Development Workflow

1. **Backend Development**: Work in `backend/` directory, use `make docker` for full environment
2. **Frontend Development**: Work in `frontend/` directory, use `npm run dev:mock` for standalone development
3. **Full Stack**: Run backend with `make docker` and frontend with `npm run dev`

## Testing Strategy

- **Backend**: Uses Go testing frameworks (testify, httpexpect, apitest)
- **Frontend**: Uses Vitest + Vue Testing Library with MSW for API mocking
- **Integration**: Tests should cover API endpoints and component interactions

## Important Notes

- Backend runs on port 8080, PostgreSQL on 15432 (to avoid WSL conflicts)
- Frontend proxy configuration handles CORS in development
- Always run commands from the appropriate subdirectory (backend/ or frontend/)
- Use Docker for consistent development environment, especially for database