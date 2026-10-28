package io.github.aoelvp94.airflow.hello;

import static java.lang.System.Logger.Level.INFO;

import org.apache.airflow.sdk.*;

/** A Dag declared entirely in Java (AIP-85), annotation style. */
@Airflow.Dag(
    id = "java_hello",
    description = "Minimal pure-Java Dag",
    schedule = "@daily",
    queue = "java",
    startDate = "2026-01-01T00:00:00Z",
    catchup = false,
    tags = {"java", "native", "demo"})
public class HelloDag {
  private static final System.Logger log = System.getLogger(HelloDag.class.getName());

  @Airflow.Task(id = "extract", retries = 1)
  public long extract() {
    log.log(INFO, "Extracting rows");
    return 42L;
  }

  @Airflow.Task(id = "transform")
  public long transform(long rows, double factor) {
    return (long) (rows * factor);
  }

  @Airflow.Task(id = "report")
  public void report(long rows) {
    log.log(INFO, "hello from Java, {0} rows", rows);
  }

  // The annotation processor generates HelloDagDeps; javac type-checks the graph.
  @Airflow.Deps
  static class Wiring implements HelloDagDeps {
    void depends() {
      report(transform(extract(), lit(1.5)));
    }
  }
}
