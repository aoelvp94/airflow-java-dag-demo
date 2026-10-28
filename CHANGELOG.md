# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-10-28

### Added
- Initial Astro CLI project structure
- Native Java DAG support on Airflow 3.4.0b2
- Multi-stage Dockerfile with Gradle and JRE 17
- Java DAG examples (ExampleJavaDAG, DataPipelineDAG)
- Python DAG coordinator for Java DAG execution
- Justfile with common development commands
- Comprehensive documentation (README, Java Guide, Troubleshooting)
- Gradle build configuration for Java DAGs
- Script to build Airflow Java SDK from source (build-sdk.sh)
- Airflow settings with java pool configuration
- Example Python DAG alongside Java DAGs
- Standard Astro project directories (dags, plugins, include, tests)

### Configuration
- Airflow 3.4.0b2 with Python 3.12
- OpenJDK 17 JRE for Java execution
- LocalExecutor for development
- Java task pool with 10 concurrent slots
- Maven local repository integration for Java SDK

### Documentation
- Main README with quick start guide
- Java DAG development guide
- Troubleshooting guide
- Inline code documentation

### Notes
- This is an unofficial configuration using Apache Airflow 3.4.0b2
- NOT compatible with Astronomer managed deployments (requires Astro Runtime)
- Designed for local development with Astro CLI only
