# airflow-java-dag-demo

Minimal Airflow 3.4 Dag written **entirely in Java** using the Java SDK (AIP-85).

- Airflow: `apache/airflow:3.4.0b2-python3.12` (pre-release — APIs are experimental)
- Java SDK: built from source at apache/airflow tag `task-sdk/1.4.0b2` (version `1.0.0-SNAPSHOT` in mavenLocal)
- Dag: `java_hello` (`extract → transform → report`), all tasks on queue `java`

## Why build the SDK from source?

Maven Central only has `org.apache.airflow:airflow-sdk:1.0.0-beta1`, which predates native Java Dags
(`@Airflow.Dag`, `DagDef`). `scripts/build-sdk.sh` clones the `java-sdk/` folder at the tag that matches the
3.4.0b2 task-sdk and runs `./gradlew publishToMavenLocal -PskipSigning=true`. The Dockerfile does the same in
its first stage, so `docker compose up --build` needs nothing on the host besides Docker.

## Layout

```text
src/main/java/io/github/aoelvp94/airflow/hello/
  HelloDag.java   # @Airflow.Dag / @Airflow.Task / @Airflow.Deps
  Main.java       # Server.create(args).serve(new Bundle().register(HelloDag.class))
build.gradle      # plugin org.apache.airflow.sdk + annotation processor
scripts/build-sdk.sh
Dockerfile        # gradle:8.14-jdk17 (SDK) → gradle (bundle) → airflow 3.4.0b2 + JRE 17
docker-compose.yml
```

`./gradlew bundle` writes `build/bundle/`; the image copies it to `/opt/airflow/dags/java/`. The `java` queue
goes to the Java coordinator:

```ini
[sdk]
coordinators = {"java": {"classpath": "airflow.sdk.coordinators.java.JavaCoordinator"}}
queue_to_coordinator = {"java": "java"}
```

(`docker-compose.yml` sets these as `AIRFLOW__SDK__*` env vars.)

## Run

Requires Docker and [`just`](https://github.com/casey/just). For host builds you also need JDK 17–21
(Gradle 8.14 does not run on JDK 25).

```bash
just up       # Postgres + Airflow standalone on http://localhost:8080
just trigger  # trigger java_hello

# optional host build
just sdk      # publish the SDK to ~/.m2
just bundle   # build/bundle/
```

`airflow standalone` prints the admin password in the container logs.

## Notes

- Airflow 3.4 drops Python 3.10; this demo uses Python 3.12.
- Based on `java-sdk/example` in [apache/airflow](https://github.com/apache/airflow/tree/main/java-sdk).
- Personal demo, not affiliated with the Apache Software Foundation.

## License

Apache-2.0 — see [LICENSE](LICENSE).
