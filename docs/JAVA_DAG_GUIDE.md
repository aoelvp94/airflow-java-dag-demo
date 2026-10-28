# Java DAG Development Guide

## Overview

This guide covers developing native Java DAGs for Airflow 3.4.0b2 using the Airflow Java SDK.

## Prerequisites

- Java 17 (JDK for development, JRE in production)
- Gradle 8.5+
- Airflow Java SDK (built via `build-sdk.sh`)

## Project Structure

```
java-dags/
├── build.gradle                    # Gradle build configuration
└── src/
    ├── main/
    │   └── java/
    │       └── com/example/airflow/dags/
    │           ├── ExampleJavaDAG.java
    │           └── DataPipelineDAG.java
    └── test/
        └── java/
            └── com/example/airflow/dags/
                └── ExampleJavaDAGTest.java
```

## Creating a New Java DAG

### 1. Create a Java Class

Create a new Java class in `java-dags/src/main/java/com/example/airflow/dags/`:

```java
package com.example.airflow.dags;

import org.apache.airflow.sdk.DAG;
import org.apache.airflow.sdk.Operator;
import org.apache.airflow.sdk.annotations.DAGDefinition;
import org.apache.airflow.sdk.operators.BashOperator;

import java.time.Duration;
import java.time.ZonedDateTime;
import java.time.ZoneId;

@DAGDefinition(
    dagId = "my_java_dag",
    schedule = "@daily",
    startDate = "2024-01-01T00:00:00Z",
    catchup = false,
    tags = {"my-tag", "java"}
)
public class MyJavaDAG {
    
    public DAG createDag() {
        DAG dag = DAG.builder()
            .dagId("my_java_dag")
            .description("My custom Java DAG")
            .schedule("@daily")
            .startDate(ZonedDateTime.of(2024, 1, 1, 0, 0, 0, 0, ZoneId.of("UTC")))
            .catchup(false)
            .dagrunTimeout(Duration.ofHours(1))
            .build();
        
        // Add tasks
        Operator task1 = BashOperator.builder()
            .taskId("task_1")
            .bashCommand("echo 'Hello from Java'")
            .pool("java")
            .build();
        
        dag.addTask(task1);
        
        return dag;
    }
}
```

### 2. Build the Java DAG

```bash
just build-java
```

Or:

```bash
cd java-dags && gradle clean build
```

### 3. Register in Python Coordinator

Add your DAG to `dags/java_dag_coordinator.py`:

```python
my_java_dag = create_java_dag_wrapper(
    dag_id='my_java_dag_wrapper',
    java_class='com.example.airflow.dags.MyJavaDAG',
    schedule='@daily',
    start_date=datetime(2024, 1, 1),
    tags=['custom'],
)
```

### 4. Test and Deploy

```bash
# Parse DAGs to validate
just parse

# Restart Airflow
just dev-restart

# Check in UI
just ui
```

## Available Operators

The Airflow Java SDK provides these operators:

- **BashOperator**: Execute bash commands
- **PythonOperator**: Execute Python functions
- **EmptyOperator**: Placeholder/dummy task
- **BranchOperator**: Conditional branching

Example:

```java
// Bash command
Operator bash = BashOperator.builder()
    .taskId("run_script")
    .bashCommand("./scripts/process.sh")
    .build();

// Empty operator (placeholder)
Operator empty = EmptyOperator.builder()
    .taskId("checkpoint")
    .build();
```

## Task Dependencies

### Linear Dependencies

```java
task1.setDownstream(task2);  // task1 -> task2
task2.setDownstream(task3);  // task2 -> task3
```

### Parallel Dependencies

```java
// Fan-out: task1 -> [task2, task3]
task1.setDownstream(task2);
task1.setDownstream(task3);

// Fan-in: [task2, task3] -> task4
task2.setDownstream(task4);
task3.setDownstream(task4);
```

### Complex Dependencies

```java
// Diamond pattern
//     task1
//    /     \
// task2   task3
//    \     /
//     task4

task1.setDownstream(task2);
task1.setDownstream(task3);
task2.setDownstream(task4);
task3.setDownstream(task4);
```

## DAG Configuration

### Schedule Intervals

```java
.schedule("@daily")         // Every day at midnight
.schedule("@hourly")        // Every hour
.schedule("0 */2 * * *")   // Every 2 hours
.schedule("0 9 * * MON")   // Every Monday at 9 AM
```

### Timeouts

```java
.dagrunTimeout(Duration.ofHours(2))      // DAG run timeout
.executionTimeout(Duration.ofMinutes(30)) // Task timeout
```

### Tags

```java
@DAGDefinition(
    // ...
    tags = {"production", "etl", "daily"}
)
```

## Best Practices

### 1. Use Meaningful IDs

```java
// Good
.dagId("customer_data_etl")
.taskId("extract_from_database")

// Bad
.dagId("dag1")
.taskId("task1")
```

### 2. Set Pools for Java Tasks

Always use the `java` pool for Java-specific tasks:

```java
Operator task = BashOperator.builder()
    .taskId("java_task")
    .bashCommand("java -jar processor.jar")
    .pool("java")  // Important!
    .build();
```

### 3. Add Descriptions

```java
DAG dag = DAG.builder()
    .dagId("my_dag")
    .description("Processes customer data from S3 and loads to warehouse")
    // ...
    .build();
```

### 4. Handle Failures Gracefully

```java
Operator task = BashOperator.builder()
    .taskId("risky_task")
    .bashCommand("./risky-script.sh")
    .retries(3)
    .retryDelay(Duration.ofMinutes(5))
    .build();
```

### 5. Use Environment Variables

```java
String dataPath = System.getenv("DATA_PATH");
String bashCmd = String.format("process_data.sh %s", dataPath);

Operator task = BashOperator.builder()
    .taskId("process_data")
    .bashCommand(bashCmd)
    .build();
```

## Testing Java DAGs

### Unit Tests

Create tests in `java-dags/src/test/java/`:

```java
package com.example.airflow.dags;

import org.junit.Test;
import static org.junit.Assert.*;

public class ExampleJavaDAGTest {
    
    @Test
    public void testDagCreation() {
        ExampleJavaDAG dagBuilder = new ExampleJavaDAG();
        DAG dag = dagBuilder.createDag();
        
        assertNotNull(dag);
        assertEquals("example_java_dag", dag.getDagId());
    }
    
    @Test
    public void testTaskCount() {
        ExampleJavaDAG dagBuilder = new ExampleJavaDAG();
        DAG dag = dagBuilder.createDag();
        
        assertEquals(4, dag.getTasks().size());
    }
}
```

### Run Tests

```bash
just test
```

## Debugging

### Check Java Version in Container

```bash
astro dev bash
java -version
echo $JAVA_HOME
```

### View Java Classpath

```bash
astro dev bash
python -c "from dags.java_dag_coordinator import get_java_classpath; print(get_java_classpath())"
```

### Test Java Execution

```bash
astro dev bash
cd /opt/airflow/java-dags
java -cp "*.jar" com.example.airflow.dags.ExampleJavaDAG
```

### Check Logs

```bash
# All logs
just dev-logs

# Specific container
docker logs <container-name>
```

## Common Issues

### ClassNotFoundException

**Problem**: Java class not found at runtime

**Solution**:
1. Rebuild Java DAGs: `just build-java`
2. Restart Airflow: `just dev-restart`
3. Check classpath includes your JAR

### Java Not Found

**Problem**: `java: command not found`

**Solution**:
1. Verify Dockerfile installs JRE 17
2. Check JAVA_HOME is set: `echo $JAVA_HOME`
3. Rebuild container: `astro dev stop && astro dev start`

### DAG Not Appearing

**Problem**: Java DAG not visible in UI

**Solution**:
1. Check Python coordinator: `dags/java_dag_coordinator.py`
2. Verify DAG is registered in coordinator
3. Parse DAGs: `just parse`
4. Check scheduler logs

## Advanced Topics

### Custom Operators

Create custom operators by extending base Operator class:

```java
public class CustomOperator extends Operator {
    // Implementation
}
```

### Dynamic DAG Generation

Generate multiple DAGs programmatically:

```java
public class DynamicDAGFactory {
    public static List<DAG> createDags(List<String> sources) {
        return sources.stream()
            .map(source -> createDagForSource(source))
            .collect(Collectors.toList());
    }
}
```

### XCom (Cross-Communication)

Share data between tasks:

```java
// Push to XCom
task1.xcomPush("my_key", "my_value");

// Pull from XCom
String value = task2.xcomPull("my_key", task1.getTaskId());
```

## Resources

- [Airflow Java SDK Documentation](https://airflow.apache.org/docs/apache-airflow/3.4.0/java-sdk.html)
- [Airflow Concepts](https://airflow.apache.org/docs/apache-airflow/stable/concepts.html)
- [DAG Best Practices](https://airflow.apache.org/docs/apache-airflow/stable/best-practices.html)

## Next Steps

1. Review example DAGs in `java-dags/src/main/java/`
2. Create your first custom Java DAG
3. Explore advanced operators and features
4. Integrate with external systems (databases, APIs, etc.)

Happy DAG development! 🚀
