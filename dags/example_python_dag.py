"""
Example Python DAG for Airflow on Astro

This demonstrates that Python DAGs work alongside Java DAGs
"""

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'example_python_dag',
    default_args=default_args,
    description='Example Python DAG on Astro with Airflow 3.4.0b2',
    schedule_interval='@daily',
    catchup=False,
    tags=['example', 'python'],
)


def print_context(**kwargs):
    """Print the execution context"""
    print(f"Execution date: {kwargs['ds']}")
    print(f"DAG run: {kwargs['dag_run']}")
    return 'Context printed successfully'


with dag:
    start = BashOperator(
        task_id='start',
        bash_command='echo "Starting Python DAG"',
    )
    
    print_info = PythonOperator(
        task_id='print_info',
        python_callable=print_context,
    )
    
    end = BashOperator(
        task_id='end',
        bash_command='echo "Python DAG completed"',
    )
    
    start >> print_info >> end
