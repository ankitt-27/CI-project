# CI Workflow

- This repository contains a comprehensive Continuous Integration (CI) workflow designed to automate the testing, security scanning, and report generation for Node.js applications.

- The pipeline integrates several OWASP tools to enhance the security and reliability of the application.

![Screenshot 2024-08-20 at 3 34 41 AM](https://github.com/user-attachments/assets/f98f7c43-678c-491a-acfb-262fcefb5ff1)

## Vulnerability Management on DefectDojo

![Screenshot 2024-08-20 at 3 36 57 AM](https://github.com/user-attachments/assets/1d600a67-0761-4ff5-a31d-86c76913f4fc)



## Workflow Overview

The CI workflow is organized into several jobs, each responsible for a specific aspect of the CI process. The jobs include:

1. **Cache Dependencies**: Caches Node.js dependencies to speed up subsequent builds.
2. **Run Tests**: Executes unit and integration tests for the application.
3. **Run GitLeaks**: Scans the codebase for sensitive information leaks using GitLeaks.
4. **Run Nodejsscan**: Performs a security scan on Node.js code with Nodejsscan.
5. **Run Semgrep**: Analyzes the codebase for security issues using Semgrep.
6. **Run Retire.js**: Detects outdated or vulnerable JavaScript libraries with Retire.js.
7. **Build and Push with Trivy**: Builds a Docker image, scans it for vulnerabilities with Trivy, and pushes it to DockerHub.
8. **Upload Reports**: Collects and uploads all generated reports to a central location.

## Workflow Details

### Cache Dependencies

- **Purpose**: Cache Node.js dependencies to reduce build time.
- **Actions**:
  - Uses the `actions/cache` action to cache `node_modules`, `yarn.lock`, and `.yarn`.

### Run Tests

- **Purpose**: Run unit and integration tests.
- **Actions**:
  - Sets up Node.js environment.
  - Restores cached dependencies.
  - Installs necessary dependencies.
  - Runs Angular CLI commands and executes tests with Karma.
  - Runs server-side tests.

### Run GitLeaks

- **Purpose**: Detect sensitive information leaks in the codebase.
- **Actions**:
  - Uses Docker to run GitLeaks.
  - Generates a JSON report of findings.

### Run Nodejsscan

- **Purpose**: Perform a security scan on Node.js code.
- **Actions**:
  - Uses the `ajinaabraham/njsscan-action` to scan for vulnerabilities.
  - Outputs results in SARIF format.

### Run Semgrep

- **Purpose**: Analyze code for security issues.
- **Actions**:
  - Runs Semgrep in a container.
  - Outputs results in JSON format.

### Run Retire.js

- **Purpose**: Detect outdated or vulnerable JavaScript libraries.
- **Actions**:
  - Installs Retire.js and necessary dependencies.
  - Scans the codebase and outputs results in JSON format.

### Build and Push with Trivy

- **Purpose**: Build a Docker image, scan for vulnerabilities, and push the image to DockerHub.
- **Actions**:
  - Builds the Docker image.
  - Runs Trivy to scan for vulnerabilities.
  - Logs in to DockerHub and pushes the image.

### Upload Reports

- **Purpose**: Collect and upload all generated security and test reports.
- **Actions**:
  - Downloads all previously generated reports.
  - Uses a Python script to upload reports to a specified location.

## Prerequisites

- Docker
- Node.js
- Yarn
- Python 3.x
- GitHub Actions

