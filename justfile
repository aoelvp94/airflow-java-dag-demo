# Airflow Java DAG Demo - Justfile

# Show available commands
default:
    @just --list

# Build the Java DAG bundle
build:
    cd java-dag && ./gradlew clean build

# Build Docker images
docker-build:
    docker-compose build

# Start Airflow with Java support
up:
    docker-compose up -d

# Stop Airflow
down:
    docker-compose down

# View logs
logs:
    docker-compose logs -f

# Restart Airflow
restart:
    docker-compose restart

# Clean everything
clean:
    cd java-dag && ./gradlew clean
    docker-compose down -v
    rm -rf logs/

# Build SDK locally (if Maven Central doesn't have DagDef)
build-sdk:
    ./scripts/build-sdk.sh

# Run full setup: build SDK, build DAG, build Docker, start
setup: build-sdk build docker-build up
    @echo "Airflow is starting... Access UI at http://localhost:8080"
    @echo "Default credentials: admin/admin"

# Check status
status:
    docker-compose ps
