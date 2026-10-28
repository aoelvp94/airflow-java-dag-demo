#!/usr/bin/env bash
set -euo pipefail

# Build Airflow Java SDK from source and install to Maven local repository
# This script builds the real Java SDK instead of using stubs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Building Airflow Java SDK..."

# Clone Airflow repository if not present
AIRFLOW_REPO_DIR="${PROJECT_ROOT}/.airflow-repo"
if [ ! -d "$AIRFLOW_REPO_DIR" ]; then
    echo "Cloning Apache Airflow repository..."
    git clone --depth 1 --branch 3.4.0b2 https://github.com/apache/airflow.git "$AIRFLOW_REPO_DIR"
fi

# Build Java SDK
cd "${AIRFLOW_REPO_DIR}/airflow/dag-processing/dag-processing-java-sdk"

echo "Building Java SDK with Gradle..."
./gradlew clean build publishToMavenLocal -x test

echo "✓ Airflow Java SDK built and published to Maven local repository"
echo "  Location: ~/.m2/repository/org/apache/airflow/"

# Copy the built artifacts to project
mkdir -p "${PROJECT_ROOT}/java-dags/libs"
cp build/libs/*.jar "${PROJECT_ROOT}/java-dags/libs/" 2>/dev/null || true

echo "✓ Build complete!"
