# Airflow 3.4 Java Native DAG Demo

This repository demonstrates a working Apache Airflow 3.4 setup with native Java DAG support using the Task SDK.

## Features

- **Airflow 3.4.0b2** with Python 3.12
- **OpenJDK 17 JRE** for Java task execution
- **Native Java DAG** using `@Dag` and `@Task` annotations
- **Gradle build** with Shadow plugin for JAR bundling
- **Docker Compose** setup with Java coordinator
- **Multi-stage Dockerfile** for optimized builds
- **Local development** environment ready to use

**Note**: This demo uses local SDK annotation stubs since Airflow 3.4.0b2 Task SDK is not yet available in Maven Central. For production use with the official SDK, update dependencies once released.

## Architecture

### Components

1. **Java DAG** (`java-dag/`): Native Java DAG implementation
   - Uses Airflow Task SDK 1.4.0b2
   - Gradle build with `org.apache.airflow.task-sdk` plugin
   - Produces bundled JAR with all dependencies

2. **Docker Setup**:
   - Multi-stage build: Gradle builder + Airflow runtime
   - Base image: `apache/airflow:3.4.0b2-python3.12`
   - OpenJDK 17 JRE installed
   - Java coordinator service for executing Java tasks

3. **Services**:
   - `airflow-webserver`: Web UI (http://localhost:8080)
   - `airflow-scheduler`: DAG scheduler
   - `airflow-worker`: Celery worker
   - `airflow-java-coordinator`: Java task coordinator (queue: `java`)
   - `postgres`: Metadata database
   - `redis`: Celery message broker

## Prerequisites

- Docker and Docker Compose
- (Optional) [just](https://github.com/casey/just) command runner
- (Optional) Java 17 and Gradle for local development

## Quick Start

### Using just

```bash
# Build and start everything
just setup

# Or step by step:
just build          # Build Java DAG
just docker-build   # Build Docker images
just up             # Start services
```

### Using Docker Compose

```bash
# Build the Java DAG and Docker images
cd java-dag && ./gradlew build && cd ..
docker-compose build

# Start Airflow
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

## Accessing Airflow

1. Wait for services to start (about 1-2 minutes)
2. Open http://localhost:8080
3. Login with default credentials:
   - **Username**: `admin`
   - **Password**: `admin`
4. Find the `demo_java_dag` in the DAGs list
5. Unpause and trigger the DAG

## Java DAG Overview

The demo DAG (`DemoJavaDag.java`) includes three tasks:

1. **hello_task**: Prints a greeting message with timestamp
2. **process_task**: Processes the message (converts to uppercase)
3. **summary_task**: Displays execution summary with context info

**Task Flow**: `hello_task` → `process_task` → `summary_task`

## Project Structure

```
.
├── java-dag/                   # Java DAG project
│   ├── src/main/java/         # Java source code
│   │   └── com/example/airflow/
│   │       └── DemoJavaDag.java
│   ├── build.gradle           # Gradle build configuration
│   ├── settings.gradle        # Gradle settings
│   └── gradlew                # Gradle wrapper
├── scripts/
│   └── build-sdk.sh           # Build Task SDK locally if needed
├── Dockerfile                 # Multi-stage Docker build
├── docker-compose.yml         # Docker Compose configuration
├── justfile                   # Just command runner recipes
├── LICENSE                    # Apache 2.0 License
├── .gitignore                # Git ignore rules
└── README.md                  # This file
```

## Building the Task SDK Locally (Optional)

This demo includes local SDK annotation stubs for demonstration purposes. If you want to use the official Airflow Task SDK once available in Maven Central or build it locally:

```bash
./scripts/build-sdk.sh
```

This will:
1. Clone the Apache Airflow repository (3.4.0b2 tag)
2. Build the Task SDK
3. Publish to local Maven repository (`~/.m2/repository`)

Then update `build.gradle` to use the official dependency:
```gradle
dependencies {
    implementation 'org.apache.airflow:airflow-task-sdk:1.4.0b2'
    // ...
}
```

## Development

### Building the Java DAG

```bash
cd java-dag
./gradlew clean build
```

The bundled JAR will be in `build/dags/`.

### Modifying the DAG

1. Edit `java-dag/src/main/java/com/example/airflow/DemoJavaDag.java`
2. Rebuild: `./gradlew build`
3. Rebuild Docker image: `docker-compose build`
4. Restart services: `docker-compose restart`

### Viewing Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f airflow-java-coordinator
docker-compose logs -f airflow-scheduler
docker-compose logs -f airflow-worker
```

## Configuration

### Java Coordinator

The Java coordinator is configured in `docker-compose.yml`:

```yaml
airflow-java-coordinator:
  command: task-sdk java-coordinator --queue java
  environment:
    AIRFLOW__TASK_SDK__JAVA_COORDINATOR_ENABLED: 'true'
    AIRFLOW__TASK_SDK__JAVA_COORDINATOR_QUEUE: 'java'
    AIRFLOW__TASK_SDK__JAVA_CLASSPATH: "/opt/airflow/dags/java/*"
```

### Environment Variables

Set in `.env` file or export before running:

```bash
AIRFLOW_UID=50000
_AIRFLOW_WWW_USER_USERNAME=admin
_AIRFLOW_WWW_USER_PASSWORD=admin
```

## Troubleshooting

### Java tasks not executing

1. Check Java coordinator logs:
   ```bash
   docker-compose logs airflow-java-coordinator
   ```

2. Verify Java is installed:
   ```bash
   docker-compose exec airflow-webserver java -version
   ```

3. Check JAR is present:
   ```bash
   docker-compose exec airflow-webserver ls -la /opt/airflow/dags/java/
   ```

### DAG not appearing in UI

1. Check scheduler logs:
   ```bash
   docker-compose logs airflow-scheduler
   ```

2. Verify DAG file syntax:
   ```bash
   cd java-dag && ./gradlew build
   ```

### Build failures

1. Ensure Java 17 is available in builder stage
2. Check Gradle build output
3. Verify dependencies are downloadable

## Cleanup

```bash
# Stop services
docker-compose down

# Remove volumes (database, logs)
docker-compose down -v

# Clean build artifacts
just clean
```

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## References

- [Apache Airflow Documentation](https://airflow.apache.org/docs/)
- [Airflow Task SDK](https://github.com/apache/airflow/tree/main/task-sdk)
- [Airflow 3.4 Release Notes](https://airflow.apache.org/docs/apache-airflow/stable/release_notes.html)

## Notes

- This is a **minimal, local-only** setup for demonstration
- For production use, add proper secrets management, monitoring, and scaling
- The beta version (3.4.0b2) may have breaking changes before final release
- Java coordinator support is still evolving in Airflow 3.x
