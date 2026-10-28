# syntax=docker/dockerfile:1
ARG AIRFLOW_REF=task-sdk/1.4.0b2

# Stage 1: build the Airflow Java SDK from source into mavenLocal.
FROM gradle:8.14-jdk17 AS sdk
ARG AIRFLOW_REF
RUN git clone --depth 1 --branch "${AIRFLOW_REF}" --filter=blob:none --sparse \
      https://github.com/apache/airflow /airflow \
 && git -C /airflow sparse-checkout set java-sdk
WORKDIR /airflow/java-sdk
RUN ./gradlew publishToMavenLocal -PskipSigning=true --no-daemon

# Stage 2: build the Dag bundle.
FROM gradle:8.14-jdk17 AS build
COPY --from=sdk /root/.m2 /root/.m2
WORKDIR /src
COPY settings.gradle build.gradle gradle.properties ./
COPY src ./src
RUN gradle bundle --no-daemon

# Stage 3: Airflow 3.4 beta + JRE 17 + the bundle in the dags folder.
FROM apache/airflow:3.4.0b2-python3.12
COPY --from=eclipse-temurin:17-jre /opt/java/openjdk /opt/java/openjdk
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
COPY --from=build --chown=airflow:root /src/build/bundle/ /opt/airflow/dags/java/
