# Airflow Java DAG Demo - Astro CLI Project

A demonstration project for running **native Java DAGs** on **Apache Airflow 3.4.0b2** using the **Astro CLI** project structure.

> ⚠️ **Important**: This project uses **Apache Airflow 3.4.0b2** (upstream), NOT Astro Runtime 3.3. This is an unofficial configuration for development and testing purposes.

## Features

- ✅ **Native Java DAG Support**: Write DAGs in Java using Airflow's Java SDK
- ✅ **Airflow 3.4.0b2**: Latest beta version with Java DAG processing support
- ✅ **JRE 17**: OpenJDK 17 runtime for Java execution
- ✅ **Astro CLI Compatible**: Standard Astro project layout with custom Dockerfile
- ✅ **Multi-stage Build**: Efficient Docker builds with Gradle for Java compilation
- ✅ **Real Java SDK**: Built from source via `build-sdk.sh` (mavenLocal)
- ✅ **Java Queue**: Dedicated pool for Java task execution
- ✅ **Python + Java**: Supports both Python and Java DAGs simultaneously

## Project Structure

```
.
├── .astro/                    # Astro CLI configuration
│   └── config.yaml
├── dags/                      # Airflow DAGs (Python)
│   ├── java_dag_coordinator.py  # Java DAG wrapper/coordinator
│   └── example_python_dag.py    # Example Python DAG
├── java-dags/                 # Java DAG source code
│   ├── build.gradle
│   └── src/main/java/com/example/airflow/dags/
│       ├── ExampleJavaDAG.java
│       └── DataPipelineDAG.java
├── scripts/
│   └── build-sdk.sh          # Build Airflow Java SDK from source
├── Dockerfile                 # Custom Airflow 3.4.0b2 + JRE 17
├── build.gradle              # Root Gradle configuration
├── settings.gradle           # Gradle multi-project setup
├── justfile                  # Task runner (just commands)
├── requirements.txt          # Python dependencies
├── packages.txt              # OS packages (via apt)
├── airflow_settings.yaml     # Airflow configuration for local dev
└── README.md                 # This file
```

## Prerequisites

1. **Astro CLI**: Install from https://docs.astronomer.io/astro/cli/install-cli
   ```bash
   # macOS
   brew install astro
   
   # Linux
   curl -sSL https://install.astronomer.io | sudo bash
   ```

2. **Just** (optional, but recommended): Command runner
   ```bash
   # macOS
   brew install just
   
   # Linux
   curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin
   ```

3. **Docker Desktop** or **Docker Engine**: Required by Astro CLI
   - macOS/Windows: https://www.docker.com/products/docker-desktop
   - Linux: Install Docker Engine + Docker Compose

## Quick Start

### Option 1: Using Just (Recommended)

```bash
# Start Astro development environment
just dev-start

# Wait for containers to start, then visit:
# http://localhost:8080
# Username: admin
# Password: admin
```

### Option 2: Using Astro CLI Directly

```bash
# Start Airflow
astro dev start

# Visit http://localhost:8080 (admin/admin)
```

### Stop the Environment

```bash
# With just
just dev-stop

# With Astro CLI
astro dev stop
```

## Building the Java SDK (Optional)

This project supports building the **real Airflow Java SDK** from source instead of using stub implementations:

```bash
# Build SDK from Airflow 3.4.0b2 source
just build-sdk

# Or run the script directly
./scripts/build-sdk.sh
```

The script will:
1. Clone Apache Airflow 3.4.0b2 repository
2. Build the Java SDK with Gradle
3. Publish to Maven local repository (~/.m2/repository)
4. Copy artifacts to `java-dags/libs/`

The Docker multi-stage build automatically uses mavenLocal when building the image.

## Java DAG Development

### Example Java DAG

Java DAGs are located in `java-dags/src/main/java/com/example/airflow/dags/`:

```java
@DAGDefinition(
    dagId = "example_java_dag",
    schedule = "0 0 * * *",
    startDate = "2024-01-01T00:00:00Z",
    catchup = false,
    tags = {"example", "java", "native"}
)
public class ExampleJavaDAG {
    public DAG createDag() {
        // Define tasks and dependencies
    }
}
```

### Building Java DAGs

```bash
# Build Java DAGs
just build-java

# Or use Gradle directly
cd java-dags && gradle clean build
```

### Java Task Queue

All Java tasks use the `java` pool by default:

```java
Operator task = BashOperator.builder()
    .taskId("my_task")
    .bashCommand("echo 'Hello from Java'")
    .pool("java")  // Uses java pool with 10 slots
    .build();
```

The java pool is configured in `airflow_settings.yaml` with 10 concurrent slots.

## Available Commands (Just)

```bash
just                  # Show all available commands
just dev-start        # Start Astro dev environment
just dev-stop         # Stop Astro dev environment
just dev-restart      # Restart Astro dev environment
just dev-logs         # Show logs
just ui               # Open Airflow UI in browser
just build-java       # Build Java DAGs
just build-sdk        # Build Airflow Java SDK from source
just test             # Run Java tests
just clean            # Clean build artifacts
just parse            # Validate DAGs
just info             # Show Astro project info
just setup            # Full setup: SDK + build + start
```

## Architecture

### Docker Multi-Stage Build

The `Dockerfile` uses a multi-stage build:

1. **Builder Stage** (`gradle:8.5-jdk17`):
   - Compiles Java DAGs
   - Builds Airflow Java SDK (if available in mavenLocal)
   - Creates JAR artifacts

2. **Runtime Stage** (`apache/airflow:3.4.0b2-python3.12`):
   - Installs JRE 17 (OpenJDK)
   - Copies compiled JARs from builder
   - Installs Python dependencies
   - Sets up Airflow configuration

### Java DAG Coordinator

The `java_dag_coordinator.py` module:
- Wraps Java DAG execution in Python DAG definitions
- Manages Java classpath including SDK and DAG JARs
- Configures Java tasks to use the `java` pool
- Registers Java DAGs with Airflow

### Execution Flow

1. Airflow scheduler scans `dags/` directory
2. Python coordinator registers Java DAG wrappers
3. When triggered, coordinator executes Java DAG class
4. Java DAG runs with full SDK support
5. Tasks execute using JRE 17 runtime

## Configuration

### Environment Variables

Set in `Dockerfile` or `.env`:

- `JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64`
- `JAVA_DAGS_PATH=/opt/airflow/java-dags`

### Airflow Settings

Configured in `airflow_settings.yaml`:

```yaml
airflow:
  pools:
    - pool_name: java
      pool_slot: 10
      pool_description: "Pool for Java DAG tasks"
  config:
    core:
      executor: LocalExecutor
      load_examples: False
```

### Astro Project

Configured in `.astro/config.yaml`:

```yaml
project:
  name: airflow-java-dag-demo
```

## Testing

### Validate DAGs

```bash
# Parse all DAGs
just parse

# Or use Astro CLI
astro dev parse
```

### Run Tests

```bash
# Run Java unit tests
just test

# Run pytest
just pytest
```

### Manual Testing

1. Start the environment: `just dev-start`
2. Visit http://localhost:8080
3. Login with `admin` / `admin`
4. Enable DAGs:
   - `example_java_dag_wrapper`
   - `java_data_pipeline_wrapper`
   - `example_python_dag`
5. Trigger DAG runs manually
6. Check logs and task execution

## Java SDK Notes

### Real SDK vs Stubs

This project is configured to use the **real Airflow Java SDK**:

- **Real SDK**: Built from Apache Airflow 3.4.0b2 source
  - Full feature support
  - Requires `build-sdk.sh` to run once
  - Published to Maven local repository
  - Used automatically in Docker build

- **Stub Implementation**: Fallback if SDK unavailable
  - Would require implementing `DAG`, `Operator`, etc. as stubs
  - Not recommended for production

### Maven Local Repository

The SDK is published to `~/.m2/repository/org/apache/airflow/`:
- `airflow-dag-processing-java-sdk/3.4.0b2/`

The Gradle build (root `build.gradle`) includes `mavenLocal()` repository.

## Important Notes

### Unofficial Configuration

⚠️ **This project uses Apache Airflow 3.4.0b2 directly, NOT Astro Runtime.**

- **Supported**: Development, testing, experimentation
- **Not Supported**: Astronomer production deployments
- **Astro Runtime**: Use official Astro Runtime images for production
- **Beta Software**: Airflow 3.4.0b2 is beta quality

### Astro CLI Compatibility

The Astro CLI project structure is fully compatible:
- Standard `dags/`, `plugins/`, `include/` directories
- Astro CLI commands work as expected
- Custom Dockerfile overrides default Astro Runtime image
- Cannot deploy to Astronomer managed services (requires Astro Runtime)

### Local Development Only

This configuration is designed for:
- ✅ Local development with `astro dev start`
- ✅ Testing Airflow 3.4.0b2 features
- ✅ Java DAG development and debugging
- ❌ Astronomer cloud deployment (requires Astro Runtime)

## Troubleshooting

### Container fails to start

Check Docker logs:
```bash
just dev-logs
```

### Java tasks fail

Verify Java installation in container:
```bash
astro dev bash
java -version
echo $JAVA_HOME
```

### DAGs not appearing

Parse DAGs to check for errors:
```bash
just parse
```

### Build fails

Clean and rebuild:
```bash
just clean
just build-java
```

## Resources

- **Astro CLI Docs**: https://docs.astronomer.io/astro/cli/overview
- **Airflow 3.4 Docs**: https://airflow.apache.org/docs/apache-airflow/3.4.0/
- **Airflow Java SDK**: https://github.com/apache/airflow/tree/main/airflow/dag-processing/dag-processing-java-sdk
- **Just Manual**: https://just.systems/man/

## License

This is a demonstration project. Refer to Apache Airflow licensing for SDK components.

## Contributing

This is a demo project for educational purposes. Feel free to fork and modify for your needs.

---

**Happy DAG Development! 🚀**

For questions or issues, refer to Apache Airflow documentation or the Astronomer community forums.
