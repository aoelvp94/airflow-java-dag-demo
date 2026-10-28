#!/usr/bin/env bash
# Build the Airflow Java SDK from source and publish it to ~/.m2 (mavenLocal).
#
# Why: Maven Central only has airflow-sdk 1.0.0-beta1, which predates native Java
# Dags (DagDef / @Airflow.Dag). We pin the SDK to the same tag as the Airflow
# 3.4.0b2 task-sdk so the bundle matches the JavaCoordinator in the image.
#
# Needs git and a JDK 17-21 (Gradle 8.14 does not run on JDK 25).
set -euo pipefail

AIRFLOW_REF="${AIRFLOW_REF:-task-sdk/1.4.0b2}"
WORKDIR="${WORKDIR:-${TMPDIR:-/tmp}/airflow-java-sdk-src}"

rm -rf "$WORKDIR"
git clone --depth 1 --branch "$AIRFLOW_REF" --filter=blob:none --sparse \
  https://github.com/apache/airflow "$WORKDIR"
git -C "$WORKDIR" sparse-checkout set java-sdk

cd "$WORKDIR/java-sdk"
./gradlew publishToMavenLocal -PskipSigning=true --no-daemon

echo "Published to ~/.m2/repository/org/apache/airflow/"
