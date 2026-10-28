# Contributing to Airflow Java DAG Demo

Thank you for your interest in contributing! This is a demonstration project showcasing native Java DAG support in Airflow.

## Development Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd airflow-java-dag-demo
   ```

2. **Install prerequisites:**
   - Astro CLI: https://docs.astronomer.io/astro/cli/install-cli
   - Just: https://just.systems/man/
   - Docker Desktop or Docker Engine

3. **Build the SDK (optional):**
   ```bash
   just build-sdk
   ```

4. **Start development environment:**
   ```bash
   just dev-start
   ```

## Making Changes

### Java DAGs

1. Add your Java DAG to `java-dags/src/main/java/com/example/airflow/dags/`
2. Build: `just build-java`
3. Register in `dags/java_dag_coordinator.py`
4. Test: `just parse` and `just dev-restart`

### Python DAGs

1. Add your Python DAG to `dags/`
2. Test: `just parse`
3. Restart: `just dev-restart`

### Documentation

- Update README.md for user-facing changes
- Update docs/ for detailed guides
- Update CHANGELOG.md for all changes

## Testing

```bash
# Parse DAGs
just parse

# Run Java tests
just test

# Manual testing
just dev-start
just ui
```

## Code Style

### Java
- Follow standard Java conventions
- Use meaningful variable and method names
- Add JavaDoc comments for public methods
- Keep methods focused and small

### Python
- Follow PEP 8
- Use type hints where appropriate
- Add docstrings for functions and classes
- Keep functions focused and testable

## Pull Request Process

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Test thoroughly
4. Update documentation
5. Update CHANGELOG.md
6. Commit with clear messages
7. Push and create a pull request

## Commit Messages

Use clear, descriptive commit messages:

```
Add Java DAG for data processing pipeline

- Implement ExampleJavaDAG with BashOperator
- Configure java pool for task execution
- Add documentation in Java Guide
```

## Questions or Issues?

- Check the [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
- Open an issue on GitHub
- Refer to [Airflow documentation](https://airflow.apache.org/docs/)

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

Thank you for contributing! 🚀
