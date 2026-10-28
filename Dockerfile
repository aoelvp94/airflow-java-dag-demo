# Multi-stage Dockerfile for Airflow 3.4 with Java native DAG support

# Stage 1: Build Java DAG
FROM gradle:8.5-jdk17 AS java-builder

WORKDIR /build

# Copy Gradle files
COPY java-dag/build.gradle java-dag/settings.gradle /build/
COPY java-dag/gradle /build/gradle/
COPY java-dag/gradlew /build/

# Download dependencies
RUN ./gradlew dependencies --no-daemon || true

# Copy source code
COPY java-dag/src /build/src/

# Build the DAG bundle
RUN ./gradlew build --no-daemon

# Stage 2: Airflow runtime with JRE
FROM apache/airflow:3.4.0b2-python3.12

# Switch to root to install JRE
USER root

# Install OpenJDK 17 JRE
RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-17-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set Java environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Create directories for Java DAGs
RUN mkdir -p /opt/airflow/dags/java && \
    chown -R airflow:root /opt/airflow/dags

# Switch back to airflow user
USER airflow

# Copy built DAG bundle from builder stage
COPY --chown=airflow:root --from=java-builder /build/build/dags/*.jar /opt/airflow/dags/java/

# Verify Java installation
RUN java -version

# Set working directory
WORKDIR /opt/airflow
