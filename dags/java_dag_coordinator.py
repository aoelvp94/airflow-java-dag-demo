"""
Java DAG Coordinator for Airflow 3.4.0b2

This module provides a Python coordinator that registers Java DAGs with Airflow.
It uses the JavaOperator to execute Java-defined DAG logic.

The coordinator:
1. Scans for compiled Java DAG classes in /opt/airflow/java-dags/
2. Registers them as Airflow DAGs with appropriate configuration
3. Ensures Java tasks run with correct classpath and JVM settings
"""

from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta
import os
import logging

logger = logging.getLogger(__name__)

# Java DAG configuration
JAVA_DAGS_PATH = os.getenv('JAVA_DAGS_PATH', '/opt/airflow/java-dags')
JAVA_HOME = os.getenv('JAVA_HOME', '/usr/lib/jvm/java-17-openjdk-amd64')

# Classpath for Java DAG execution
def get_java_classpath():
    """Build classpath including all JARs in java-dags directory"""
    classpath_entries = []
    
    if os.path.exists(JAVA_DAGS_PATH):
        for root, dirs, files in os.walk(JAVA_DAGS_PATH):
            for file in files:
                if file.endswith('.jar'):
                    classpath_entries.append(os.path.join(root, file))
    
    # Add Maven local repository for Airflow SDK
    maven_repo = os.path.expanduser('~/.m2/repository')
    if os.path.exists(maven_repo):
        airflow_sdk_path = os.path.join(
            maven_repo,
            'org/apache/airflow/airflow-dag-processing-java-sdk'
        )
        if os.path.exists(airflow_sdk_path):
            for root, dirs, files in os.walk(airflow_sdk_path):
                for file in files:
                    if file.endswith('.jar'):
                        classpath_entries.append(os.path.join(root, file))
    
    return ':'.join(classpath_entries) if classpath_entries else ''


def create_java_dag_wrapper(dag_id, java_class, schedule, start_date, **kwargs):
    """
    Create a Python DAG that wraps Java DAG execution
    
    Args:
        dag_id: Unique identifier for the DAG
        java_class: Fully qualified Java class name
        schedule: Schedule interval for the DAG
        start_date: Start date for the DAG
        **kwargs: Additional DAG arguments
    """
    default_args = {
        'owner': 'airflow',
        'depends_on_past': False,
        'email_on_failure': False,
        'email_on_retry': False,
        'retries': 1,
        'retry_delay': timedelta(minutes=5),
    }
    default_args.update(kwargs.get('default_args', {}))
    
    dag = DAG(
        dag_id=dag_id,
        default_args=default_args,
        description=f'Java DAG: {java_class}',
        schedule_interval=schedule,
        start_date=start_date,
        catchup=kwargs.get('catchup', False),
        tags=['java', 'native'] + kwargs.get('tags', []),
    )
    
    with dag:
        # Execute Java DAG
        classpath = get_java_classpath()
        java_cmd = f"""
            export JAVA_HOME={JAVA_HOME}
            export PATH=$JAVA_HOME/bin:$PATH
            java -cp "{classpath}" {java_class}
        """
        
        execute_java = BashOperator(
            task_id='execute_java_dag',
            bash_command=java_cmd,
            pool='java',
        )
    
    return dag


# Register Java DAGs
# These DAGs are discovered and registered automatically

# Example Java DAG
example_java_dag = create_java_dag_wrapper(
    dag_id='example_java_dag_wrapper',
    java_class='com.example.airflow.dags.ExampleJavaDAG',
    schedule='@daily',
    start_date=datetime(2024, 1, 1),
    tags=['example'],
)

# Data Pipeline DAG
data_pipeline_dag = create_java_dag_wrapper(
    dag_id='java_data_pipeline_wrapper',
    java_class='com.example.airflow.dags.DataPipelineDAG',
    schedule='0 6 * * *',
    start_date=datetime(2024, 1, 1),
    tags=['pipeline', 'etl'],
)

logger.info(f"Java DAG Coordinator initialized. Classpath: {get_java_classpath()}")
