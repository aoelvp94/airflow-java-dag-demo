package com.example.airflow.dags;

import org.apache.airflow.sdk.DAG;
import org.apache.airflow.sdk.Operator;
import org.apache.airflow.sdk.annotations.DAGDefinition;
import org.apache.airflow.sdk.operators.BashOperator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Duration;
import java.time.ZonedDateTime;
import java.time.ZoneId;

/**
 * Example Java DAG demonstrating native Java DAG authoring on Airflow 3.4.0b2
 * 
 * This DAG showcases:
 * - Native Java DAG definition using Airflow Java SDK
 * - BashOperator usage
 * - Task dependencies
 * - Scheduling and configuration
 */
@DAGDefinition(
    dagId = "example_java_dag",
    schedule = "0 0 * * *",
    startDate = "2024-01-01T00:00:00Z",
    catchup = false,
    tags = {"example", "java", "native"}
)
public class ExampleJavaDAG {
    
    private static final Logger logger = LoggerFactory.getLogger(ExampleJavaDAG.class);
    
    public DAG createDag() {
        logger.info("Creating ExampleJavaDAG");
        
        DAG dag = DAG.builder()
            .dagId("example_java_dag")
            .description("Example Java DAG with native Java operators")
            .schedule("0 0 * * *")
            .startDate(ZonedDateTime.of(2024, 1, 1, 0, 0, 0, 0, ZoneId.of("UTC")))
            .catchup(false)
            .dagrunTimeout(Duration.ofHours(1))
            .build();
        
        // Task 1: Print start message
        Operator startTask = BashOperator.builder()
            .taskId("start_task")
            .bashCommand("echo 'Starting Java DAG execution'")
            .pool("java")
            .build();
        
        // Task 2: Print Java version
        Operator javaVersionTask = BashOperator.builder()
            .taskId("print_java_version")
            .bashCommand("java -version 2>&1 | head -n 1")
            .pool("java")
            .build();
        
        // Task 3: Print environment info
        Operator envInfoTask = BashOperator.builder()
            .taskId("print_env_info")
            .bashCommand("echo 'JAVA_HOME='$JAVA_HOME && echo 'PATH='$PATH")
            .pool("java")
            .build();
        
        // Task 4: Completion message
        Operator endTask = BashOperator.builder()
            .taskId("end_task")
            .bashCommand("echo 'Java DAG execution completed successfully'")
            .pool("java")
            .build();
        
        // Set dependencies: start -> [java_version, env_info] -> end
        dag.addTask(startTask);
        dag.addTask(javaVersionTask);
        dag.addTask(envInfoTask);
        dag.addTask(endTask);
        
        startTask.setDownstream(javaVersionTask);
        startTask.setDownstream(envInfoTask);
        javaVersionTask.setDownstream(endTask);
        envInfoTask.setDownstream(endTask);
        
        return dag;
    }
}
