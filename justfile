# Build + publish the Java SDK (tag task-sdk/1.4.0b2) into ~/.m2
sdk:
    ./scripts/build-sdk.sh

# Build the Dag bundle into build/bundle/ (needs `just sdk` first)
bundle:
    ./gradlew bundle

build:
    docker compose build

up:
    docker compose up --build

down:
    docker compose down -v

trigger:
    docker compose exec airflow airflow dags trigger java_hello

logs:
    docker compose logs -f airflow
