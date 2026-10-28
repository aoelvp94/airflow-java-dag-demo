# Troubleshooting Guide

## Common Issues and Solutions

### 1. Container Fails to Start

#### Symptoms
- `astro dev start` hangs or fails
- Container exits immediately
- Docker errors

#### Solutions

**Check Docker Resources:**
```bash
docker system df
docker system prune  # Clean up if needed
```

**Check Container Logs:**
```bash
astro dev logs
# Or
docker ps -a
docker logs <container-id>
```

**Rebuild Image:**
```bash
astro dev stop
astro dev kill
astro dev start --force-build
```

### 2. Java Not Available

#### Symptoms
- `java: command not found`
- Tasks fail with Java errors
- JRE not installed

#### Solutions

**Verify in Container:**
```bash
astro dev bash
java -version
echo $JAVA_HOME
which java
```

**Check Dockerfile:**
Ensure JRE installation step is present:
```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless
```

**Rebuild Container:**
```bash
astro dev stop
astro dev start --force-build
```

### 3. DAGs Not Appearing

#### Symptoms
- DAGs missing from UI
- Empty DAG list
- DAG parsing errors

#### Solutions

**Parse DAGs:**
```bash
just parse
# Or
astro dev parse
```

**Check DAG Directory:**
```bash
astro dev bash
ls -la /usr/local/airflow/dags
cat /usr/local/airflow/dags/java_dag_coordinator.py
```

**Check Scheduler Logs:**
```bash
just dev-logs | grep scheduler
```

**Verify Python Syntax:**
```bash
astro dev bash
python -m py_compile /usr/local/airflow/dags/*.py
```

### 4. Java DAG Execution Fails

#### Symptoms
- Java tasks fail
- ClassNotFoundException
- JAR not found

#### Solutions

**Check Java Classpath:**
```bash
astro dev bash
python3 << EOF
from dags.java_dag_coordinator import get_java_classpath
print(get_java_classpath())
EOF
```

**Verify JARs Present:**
```bash
astro dev bash
ls -la /opt/airflow/java-dags/
find /opt/airflow/java-dags -name "*.jar"
```

**Rebuild Java DAGs:**
```bash
just build-java
astro dev restart
```

**Test Java Execution Manually:**
```bash
astro dev bash
cd /opt/airflow/java-dags
java -version
# Try running a simple Java command
```

### 5. Build Errors

#### Symptoms
- Gradle build fails
- Docker build fails
- Compilation errors

#### Solutions

**Clean and Rebuild:**
```bash
just clean
just build-java
```

**Check Gradle Daemon:**
```bash
cd java-dags
gradle --stop
gradle clean build
```

**Verify Java SDK:**
```bash
ls -la ~/.m2/repository/org/apache/airflow/
```

**Build SDK from Source:**
```bash
just build-sdk
```

### 6. Permission Errors

#### Symptoms
- Permission denied errors
- Cannot write to directories
- File access errors

#### Solutions

**Check File Ownership:**
```bash
astro dev bash
ls -la /opt/airflow/
ls -la /opt/airflow/java-dags/
```

**Fix in Dockerfile:**
Ensure proper ownership:
```dockerfile
RUN chown -R airflow:root /opt/airflow/java-dags
```

**Rebuild:**
```bash
astro dev stop
astro dev start --force-build
```

### 7. Memory Issues

#### Symptoms
- Container OOM killed
- Build process crashes
- Slow performance

#### Solutions

**Increase Docker Memory:**
- Docker Desktop → Settings → Resources → Memory
- Increase to 8GB or more

**Check Memory Usage:**
```bash
docker stats
```

**Limit Gradle Memory:**
Add to `gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx2g -XX:MaxMetaspaceSize=512m
```

### 8. Network Issues

#### Symptoms
- Cannot access Airflow UI
- Port already in use
- Connection refused

#### Solutions

**Check Ports:**
```bash
# Check if port 8080 is available
lsof -i :8080
netstat -an | grep 8080
```

**Use Different Port:**
Edit `.astro/config.yaml`:
```yaml
project:
  name: airflow-java-dag-demo
  port: 8081  # Change port
```

**Kill Conflicting Process:**
```bash
# Find process on port 8080
lsof -ti :8080 | xargs kill -9
```

### 9. Database Issues

#### Symptoms
- Cannot initialize database
- Database connection errors
- Migration failures

#### Solutions

**Reset Database:**
```bash
astro dev stop
# Remove volumes
docker volume ls | grep airflow-java-dag-demo
docker volume rm <volume-name>
astro dev start
```

**Check Database:**
```bash
astro dev bash
airflow db check
airflow db migrate
```

### 10. Scheduler Not Running

#### Symptoms
- DAGs not being scheduled
- No task executions
- Scheduler logs show errors

#### Solutions

**Check Scheduler Status:**
```bash
docker ps | grep scheduler
astro dev logs scheduler
```

**Restart Scheduler:**
```bash
astro dev restart
```

**Check Scheduler Configuration:**
```bash
astro dev bash
airflow config get-value scheduler scheduler_heartbeat_sec
```

## Debugging Commands

### Container Access
```bash
# Access Airflow container
astro dev bash

# Access as root
docker exec -it --user root <container-id> bash
```

### Log Access
```bash
# All logs
astro dev logs

# Follow logs
astro dev logs --follow

# Specific service
docker logs <container-name>
```

### Airflow CLI
```bash
astro dev bash

# List DAGs
airflow dags list

# Test DAG
airflow dags test <dag-id> 2024-01-01

# Test task
airflow tasks test <dag-id> <task-id> 2024-01-01

# Show DAG
airflow dags show <dag-id>
```

### Java Debugging
```bash
astro dev bash

# Java version
java -version

# Java home
echo $JAVA_HOME

# Find JARs
find / -name "*.jar" 2>/dev/null | grep airflow

# Test Java execution
java -cp "/opt/airflow/java-dags/*.jar" com.example.airflow.dags.ExampleJavaDAG
```

### Gradle Debugging
```bash
cd java-dags

# Clean build
gradle clean build --info

# Show dependencies
gradle dependencies

# Check configuration
gradle tasks --all
```

## Getting Help

### Check Logs First
Always start by checking logs:
```bash
just dev-logs
```

### Enable Debug Logging
Add to `airflow_settings.yaml`:
```yaml
airflow:
  config:
    logging:
      logging_level: DEBUG
```

### Community Resources
- [Airflow Slack](https://apache-airflow-slack.herokuapp.com/)
- [Astronomer Forum](https://forum.astronomer.io/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/airflow)
- [GitHub Issues](https://github.com/apache/airflow/issues)

## Reporting Issues

When reporting issues, include:

1. **Environment Info:**
   ```bash
   astro version
   docker --version
   java -version
   ```

2. **Error Logs:**
   ```bash
   astro dev logs > logs.txt
   ```

3. **Configuration:**
   - Dockerfile
   - airflow_settings.yaml
   - Relevant DAG code

4. **Steps to Reproduce:**
   - What commands did you run?
   - What did you expect?
   - What actually happened?

## Preventive Maintenance

### Regular Cleanup
```bash
# Clean Docker
docker system prune -a

# Clean Gradle cache
gradle clean
rm -rf ~/.gradle/caches

# Clean Astro cache
rm -rf .astro/dag_test_cache
```

### Update Dependencies
```bash
# Update Python packages
pip list --outdated
# Update requirements.txt as needed

# Update Gradle wrapper
./gradlew wrapper --gradle-version=8.5
```

### Monitor Resources
```bash
# Docker disk usage
docker system df

# Container stats
docker stats

# Check logs size
du -sh ~/.astro/
```

## Best Practices

1. **Always use version control** - Commit working configurations
2. **Test locally first** - Before deploying to production
3. **Keep logs** - Enable log persistence for debugging
4. **Document changes** - Note what you changed and why
5. **Use tags** - Tag working Docker images
6. **Backup data** - Export important DAG configurations

---

If you encounter an issue not covered here, please check the [Airflow documentation](https://airflow.apache.org/docs/) or ask in the community forums.
