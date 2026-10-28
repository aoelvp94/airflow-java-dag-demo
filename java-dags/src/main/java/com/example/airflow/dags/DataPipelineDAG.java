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
 * Data processing pipeline example using Java
 * 
 * Demonstrates a typical ETL workflow:
 * - Extract data
 * - Transform data
 * - Load data
 * - Validate results
 */
@DAGDefinition(
    dagId = "java_data_pipeline",
    schedule = "0 6 * * *",
    startDate = "2024-01-01T00:00:00Z",
    catchup = false,
    tags = {"pipeline", "etl", "java"}
)
public class DataPipelineDAG {
    
    private static final Logger logger = LoggerFactory.getLogger(DataPipelineDAG.class);
    
    public DAG createDag() {
        logger.info("Creating Java Data Pipeline DAG");
        
        DAG dag = DAG.builder()
            .dagId("java_data_pipeline")
            .description("ETL pipeline implemented in Java")
            .schedule("0 6 * * *")
            .startDate(ZonedDateTime.of(2024, 1, 1, 0, 0, 0, 0, ZoneId.of("UTC")))
            .catchup(false)
            .dagrunTimeout(Duration.ofHours(2))
            .build();
        
        // Extract phase
        Operator extractTask = BashOperator.builder()
            .taskId("extract_data")
            .bashCommand("echo 'Extracting data from source...' && sleep 2 && echo 'Extract complete'")
            .pool("java")
            .build();
        
        // Transform phase
        Operator transformTask = BashOperator.builder()
            .taskId("transform_data")
            .bashCommand("echo 'Transforming data...' && sleep 3 && echo 'Transform complete'")
            .pool("java")
            .build();
        
        // Load phase
        Operator loadTask = BashOperator.builder()
            .taskId("load_data")
            .bashCommand("echo 'Loading data to destination...' && sleep 2 && echo 'Load complete'")
            .pool("java")
            .build();
        
        // Validation phase
        Operator validateTask = BashOperator.builder()
            .taskId("validate_results")
            .bashCommand("echo 'Validating pipeline results...' && sleep 1 && echo 'Validation passed'")
            .pool("java")
            .build();
        
        // Add tasks to DAG
        dag.addTask(extractTask);
        dag.addTask(transformTask);
        dag.addTask(loadTask);
        dag.addTask(validateTask);
        
        // Set linear dependencies: extract -> transform -> load -> validate
        extractTask.setDownstream(transformTask);
        transformTask.setDownstream(loadTask);
        loadTask.setDownstream(validateTask);
        
        return dag;
    }
}
