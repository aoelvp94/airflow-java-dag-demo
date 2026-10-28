# Multi-stage build for Java DAG support on Airflow 3.4.0b2
FROM gradle:8.5-jdk17 AS java-builder

WORKDIR /build

# Copy Java source and build files
COPY java-dags/ ./java-dags/
COPY build.gradle settings.gradle gradlew ./
COPY gradle/ ./gradle/

# Build Java DAGs and Airflow Java SDK
RUN cd java-dags && gradle clean build publishToMavenLocal -x test

# Final Airflow image
FROM apache/airflow:3.4.0b2-python3.12

USER root

# Install JRE 17 for running Java DAGs
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Copy built JARs from builder stage
COPY --from=java-builder /root/.m2/repository/org/apache/airflow /home/airflow/.m2/repository/org/apache/airflow
COPY --from=java-builder /build/java-dags/build/libs/*.jar /opt/airflow/java-dags/

# Ensure correct permissions
RUN chown -R airflow:root /opt/airflow/java-dags /home/airflow/.m2 && \
    chmod -R 775 /opt/airflow/java-dags

USER airflow

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy Airflow configuration and DAGs
COPY --chown=airflow:root . .
