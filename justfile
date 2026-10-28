# Justfile for Astro CLI operations
# https://github.com/casey/just

# Default recipe - show available commands
default:
    @just --list

# Start Astro dev environment
dev-start:
    @echo "Starting Astro development environment..."
    astro dev start

# Stop Astro dev environment
dev-stop:
    @echo "Stopping Astro development environment..."
    astro dev stop

# Restart Astro dev environment
dev-restart:
    @echo "Restarting Astro development environment..."
    astro dev restart

# Show Astro dev logs
dev-logs:
    astro dev logs

# Open Airflow UI in browser
ui:
    @echo "Opening Airflow UI at http://localhost:8080"
    @echo "Default credentials: admin / admin"
    open http://localhost:8080 || xdg-open http://localhost:8080 || echo "Visit http://localhost:8080"

# Build Java DAGs
build-java:
    @echo "Building Java DAGs..."
    cd java-dags && gradle clean build

# Build Airflow Java SDK from source
build-sdk:
    @echo "Building Airflow Java SDK from source..."
    ./scripts/build-sdk.sh

# Run tests
test:
    @echo "Running tests..."
    cd java-dags && gradle test

# Clean build artifacts
clean:
    @echo "Cleaning build artifacts..."
    cd java-dags && gradle clean
    rm -rf .astro/dag_test_cache

# Parse DAGs (test DAG validity)
parse:
    @echo "Parsing DAGs..."
    astro dev parse

# Execute pytest in Airflow container
pytest:
    astro dev pytest

# Show Astro project info
info:
    astro dev object export

# Initialize project (run after clone)
init:
    @echo "Initializing project..."
    @echo "1. Install Astro CLI: https://docs.astronomer.io/astro/cli/install-cli"
    @echo "2. Run: just build-sdk (optional, for real SDK)"
    @echo "3. Run: just dev-start"
    @echo "4. Open: http://localhost:8080 (admin/admin)"

# Full setup with SDK build
setup: build-sdk build-java dev-start
    @echo "Setup complete! Airflow UI: http://localhost:8080"
