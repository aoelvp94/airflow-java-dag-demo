#!/bin/bash
set -e

echo "Building Airflow Task SDK 1.4.0b2 locally..."

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Clone Airflow repository
echo "Cloning Apache Airflow repository..."
git clone --depth 1 --branch 3.4.0b2 https://github.com/apache/airflow.git

cd airflow/task-sdk

# Build and publish to Maven Local
echo "Building and publishing to Maven Local..."
./gradlew publishToMavenLocal

echo "SDK built and published to ~/.m2/repository"
echo "Cleaning up..."
rm -rf "$TEMP_DIR"

echo "Done!"
