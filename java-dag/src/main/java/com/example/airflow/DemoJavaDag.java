package com.example.airflow;

import org.apache.airflow.sdk.api.Dag;
import org.apache.airflow.sdk.api.Task;
import org.apache.airflow.sdk.api.Context;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;

/**
 * Demo Java DAG for Airflow 3.4
 * 
 * This demonstrates a native Java DAG with multiple tasks
 * using the Task SDK annotations.
 */
@Dag(
    dagId = "demo_java_dag",
    description = "Demo Java DAG using Airflow 3.4 Task SDK",
    schedule = "@daily",
    tags = {"demo", "java", "native"}
)
public class DemoJavaDag {
    
    private static final Logger logger = LoggerFactory.getLogger(DemoJavaDag.class);

    /**
     * First task: Print hello message
     */
    @Task(taskId = "hello_task")
    public String helloTask(Context context) {
        String logicalDate = context.getLogicalDate();
        logger.info("Hello from Java Task SDK!");
        logger.info("Logical date: {}", logicalDate);
        
        String message = "Hello from Airflow 3.4 Java DAG at " + 
                        LocalDateTime.now().toString();
        logger.info("Message: {}", message);
        
        return message;
    }

    /**
     * Second task: Process the message
     */
    @Task(taskId = "process_task", dependencies = {"hello_task"})
    public String processTask(String message, Context context) {
        logger.info("Processing message: {}", message);
        
        String processed = message.toUpperCase() + " - PROCESSED";
        logger.info("Processed result: {}", processed);
        
        return processed;
    }

    /**
     * Third task: Generate summary
     */
    @Task(taskId = "summary_task", dependencies = {"process_task"})
    public void summaryTask(String processedMessage, Context context) {
        logger.info("=== DAG Execution Summary ===");
        logger.info("DAG ID: {}", context.getDagId());
        logger.info("Run ID: {}", context.getRunId());
        logger.info("Task ID: {}", context.getTaskId());
        logger.info("Logical Date: {}", context.getLogicalDate());
        logger.info("Processed Message: {}", processedMessage);
        logger.info("Execution completed successfully!");
        logger.info("============================");
    }
}
